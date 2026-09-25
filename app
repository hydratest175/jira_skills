"""Read-only MCP tools for all configured Jira REST v2 connectors."""

import asyncio
import logging
from collections.abc import Awaitable, Callable
from typing import Any

import httpx
from fastmcp import Context, FastMCP
from pydantic import BaseModel, ValidationError

from app.connector_tokens import get_all_connectors_for_type
from app.jira_client import (
    jira_get,
    jira_post,
    parse_comment,
    parse_issue,
    parse_page_metadata,
    parse_project,
    parse_search_issue,
)
from app.jira_errors import JiraToolError, upstream_error
from app.jira_models import (
    JiraBatchItem,
    JiraBatchResult,
    JiraBoard,
    JiraBoardPage,
    JiraCommentPage,
    JiraDetailLevel,
    JiraError,
    JiraIssue,
    JiraIssueSearchPage,
    JiraIssueSummary,
    JiraProject,
    JiraSprint,
    JiraSprintPage,
)
from app.tool_inputs import (
    JiraBatchInput,
    JiraBoardListInput,
    JiraInstanceInput,
    JiraIssueKeyInput,
    JiraIssueSearchInput,
    JiraPageInput,
    JiraSprintIssuesInput,
    JiraSprintListInput,
)

logger = logging.getLogger(__name__)
CONNECTOR_TYPE = "jira"
_READ_ONLY = {"readOnlyHint": True, "destructiveHint": False, "idempotentHint": True}
_SUMMARY_FIELDS = [
    "summary",
    "project",
    "status",
    "priority",
    "assignee",
    "issuetype",
    "updated",
    "labels",
    "components",
]
_ISSUE_FIELDS = [
    *_SUMMARY_FIELDS,
    "description",
    "reporter",
    "created",
    "comment",
    "parent",
    "subtasks",
    "issuelinks",
    "fixVersions",
    "duedate",
    "resolution",
]


def _escape_jql_value(value: str) -> str:
    return value.replace("\\", r"\\").replace('"', r"\"")


def _build_jira_search_jql(search_input: JiraIssueSearchInput) -> str:
    """Keep precedence: explicit JQL, issue key, then structured filters."""
    if search_input.jql:
        return search_input.jql
    if search_input.issue_key:
        return f'key = "{search_input.issue_key}"'
    parts: list[str] = []
    for attribute, field in (
        ("project", "project"),
        ("status", "status"),
        ("sprint", "sprint"),
        ("assignee", "assignee"),
        ("reporter", "reporter"),
        ("issue_type", "issuetype"),
        ("priority", "priority"),
        ("fix_version", "fixVersion"),
        ("component", "component"),
    ):
        value = getattr(search_input, attribute)
        if not value:
            continue
        if attribute in ("assignee", "reporter") and value.lower() == "currentuser":
            parts.append(f"{field} = currentUser()")
        else:
            parts.append(f'{field} = "{_escape_jql_value(value)}"')
    labels = [s.strip() for s in search_input.labels.split(",") if s.strip()]
    if len(labels) == 1:
        parts.append(f'labels = "{_escape_jql_value(labels[0])}"')
    elif labels:
        joined = ", ".join(f'"{_escape_jql_value(s)}"' for s in labels)
        parts.append(f"labels in ({joined})")
    if search_input.query:
        parts.append(f'text ~ "{_escape_jql_value(search_input.query)}"')
    prefix = " AND ".join(parts)
    # Tie-breaker gives deterministic ordering for equal update timestamps.
    return (prefix + " " if prefix else "") + "ORDER BY updated DESC, key ASC"


def _log_exc(label: str, _instance_url: str, exc: Exception) -> None:
    """Log bounded error categories, without credentials, payloads or URLs."""
    status = exc.response.status_code if isinstance(exc, httpx.HTTPStatusError) else None
    logger.warning("%s failed: type=%s status=%s", label, type(exc).__name__, status)


def _validated[T: BaseModel](model: type[T], operation: str, **values: Any) -> T:
    try:
        return model.model_validate(values)
    except ValidationError as exc:
        # Validation messages can contain input values: return field paths only.
        fields = ", ".join(".".join(map(str, e["loc"])) or "input" for e in exc.errors())
        raise JiraToolError(
            JiraError(
                code="INVALID_INPUT",
                message=f"Invalid fields: {fields}. Check the tool schema.",
                operation=operation,
            )
        ) from None


async def _resolve_connectors(
    ctx: Context,
    instance_url: str,
    operation: str = "resolve_connectors",
    *,
    single: bool = False,
) -> tuple[httpx.AsyncClient, list[tuple[str, str]]]:
    try:
        client: httpx.AsyncClient = ctx.lifespan_context["http_clients"].get_async_client()
        connectors = await get_all_connectors_for_type(CONNECTOR_TYPE, client)
    except Exception as exc:
        _log_exc(operation, "", exc)
        raise JiraToolError(
            JiraError(
                code="CONNECTOR_UNAVAILABLE",
                message="Could not resolve Jira connectors for this request.",
                operation=operation,
            )
        ) from None
    if instance_url:
        connectors = [(url, token) for url, token in connectors if url.rstrip("/") == instance_url]
        if not connectors:
            raise JiraToolError(
                JiraError(
                    code="UNKNOWN_INSTANCE",
                    message="Select an instance from the configured Jira connectors.",
                    operation=operation,
                )
            )
    if not connectors:
        raise JiraToolError(
            JiraError(
                code="CONNECTOR_UNAVAILABLE",
                message="No Jira connector is configured for this request.",
                operation=operation,
            )
        )
    if single and len(connectors) != 1:
        raise JiraToolError(
            JiraError(
                code="AMBIGUOUS_INSTANCE",
                message="Several connectors exist. Specify instance_url.",
                operation=operation,
            )
        )
    return client, connectors


async def _collect[T](
    connectors: list[tuple[str, str]],
    label: str,
    operation: Callable[[str, str], Awaitable[T]],
    *,
    missing_issue: str = "",
    error_page: Callable[[str, JiraError], T] | None = None,
) -> list[T]:
    """Pages report per-instance failures; legacy flat lists fail explicitly."""
    results: list[T] = []
    for instance_url, token in connectors:
        try:
            results.append(await operation(instance_url, token))
        except Exception as exc:
            error = upstream_error(exc, label, instance_url)
            if error_page is not None:
                results.append(error_page(instance_url, error))
                continue
            if missing_issue and error.http_status == 404:
                continue
            _log_exc(label, instance_url, exc)
            raise JiraToolError(error) from None
    if missing_issue and not results:
        raise JiraToolError(
            JiraError(
                code="NOT_FOUND_OR_INACCESSIBLE",
                message=f"Issue {missing_issue} was not found or is not visible.",
                operation=label,
            )
        )
    return results


def _search_fields(detail_level: JiraDetailLevel) -> list[str]:
    if detail_level == "compact":
        return ["summary"]
    if detail_level == "standard":
        return list(_SUMMARY_FIELDS)
    return [
        *_SUMMARY_FIELDS,
        "description",
        "reporter",
        "created",
        "duedate",
        "resolution",
        "fixVersions",
    ]


def _issue_page(
    url: str,
    raw: dict[str, Any],
    search: JiraIssueSearchInput | JiraSprintIssuesInput,
    jql: str,
    fields: list[str],
) -> JiraIssueSearchPage:
    issues = [
        parse_search_issue(url, i, search.detail_level, search.description_limit)
        for i in raw["issues"]
    ]
    result = JiraIssueSearchPage(
        **parse_page_metadata(url, raw, len(issues), search.start_at, search.max_results),
        issues=issues,
        warnings=raw.get("warningMessages") or [],
        detail_level=search.detail_level,
        fields_requested=fields,
        effective_jql=jql,
        content_truncated=any(i.description_truncated for i in issues),
        sprint_id=search.sprint_id if isinstance(search, JiraSprintIssuesInput) else None,
    )
    if result.warnings or result.content_truncated:
        result.complete = False
    return result


def _failed_page(url: str, page: JiraPageInput, error: JiraError) -> dict[str, Any]:
    return {
        "instance_url": url,
        "start_at": page.start_at,
        "max_results": page.max_results,
        "returned_count": 0,
        "status": "error",
        "error": error,
        "complete": False,
    }


async def _search_pages(ctx: Context, search: JiraIssueSearchInput) -> list[JiraIssueSearchPage]:
    client, connectors = await _resolve_connectors(
        ctx, search.instance_url, "jira_search_issues_page"
    )
    jql = _build_jira_search_jql(search)
    fields = _search_fields(search.detail_level)

    async def fetch(instance_url: str, token: str) -> JiraIssueSearchPage:
        raw = await jira_post(
            client,
            instance_url,
            token,
            "/search",
            body={
                "jql": jql,
                "startAt": search.start_at,
                "maxResults": search.max_results,
                "fields": fields,
            },
        )
        return _issue_page(instance_url, raw, search, jql, fields)

    return await _collect(
        connectors,
        "jira_search_issues_page",
        fetch,
        error_page=lambda url, error: JiraIssueSearchPage(
            **_failed_page(url, search, error),
            detail_level=search.detail_level,
            fields_requested=fields,
            effective_jql=jql,
        ),
    )


def register_jira_tools(mcp: FastMCP) -> None:
    """Register nine read-only Jira tools. Hide the legacy search in agent allowlists."""

    @mcp.tool(annotations=_READ_ONLY)
    async def jira_list_projects(ctx: Context, instance_url: str = "") -> list[JiraProject]:
        """List visible projects from all configured Jira connectors.

        Args:
            instance_url: Optional exact configured Jira base URL to select one instance.
        """
        selected = _validated(JiraInstanceInput, "jira_list_projects", instance_url=instance_url)
        client, connectors = await _resolve_connectors(ctx, selected.instance_url)

        async def fetch(url: str, token: str) -> list[JiraProject]:
            raw = await jira_get(client, url, token, "/project")
            if not isinstance(raw, list):
                raise ValueError("Unexpected Jira project response")
            return [parse_project(url, project) for project in raw]

        groups = await _collect(connectors, "jira_list_projects", fetch)
        return [project for group in groups for project in group]

    @mcp.tool(annotations=_READ_ONLY)
    async def jira_search_issues(
        ctx: Context,
        issue_key: str = "",
        project: str = "",
        status: str = "",
        sprint: str = "",
        assignee: str = "",
        reporter: str = "",
        issue_type: str = "",
        priority: str = "",
        labels: str = "",
        fix_version: str = "",
        component: str = "",
        query: str = "",
        jql: str = "",
        max_results: int = 50,
        start_at: int = 0,
        instance_url: str = "",
    ) -> list[JiraIssueSummary]:
        """Search Jira, returning the legacy flat list with enriched summaries.

        Args:
            issue_key: Exact issue key; overrides structured filters.
            project: Project key.
            status: Status name.
            sprint: Sprint name.
            assignee: Username or currentuser.
            reporter: Username or currentuser.
            issue_type: Issue type name.
            priority: Priority name.
            labels: Comma-separated labels; matches any listed label.
            fix_version: Fix version name.
            component: Component name.
            query: Jira text-search expression; Jira text-search syntax applies.
            jql: Raw JQL, overriding all structured filters and issue_key.
            max_results: Page size per instance, 1 to 100; not a global limit.
            start_at: Offset per instance, starting at zero.
            instance_url: Optional exact configured Jira base URL.

        Use jira_search_issues_page to obtain totals and next offsets. A flat
        list is only one page per instance, not necessarily all matching issues.
        """
        search = _validated(
            JiraIssueSearchInput,
            "jira_search_issues",
            issue_key=issue_key,
            project=project,
            status=status,
            sprint=sprint,
            assignee=assignee,
            reporter=reporter,
            issue_type=issue_type,
            priority=priority,
            labels=labels,
            fix_version=fix_version,
            component=component,
            query=query,
            jql=jql,
            max_results=max_results,
            start_at=start_at,
            instance_url=instance_url,
        )
        pages = await _search_pages(ctx, search)
        for page in pages:
            if page.error is not None:
                raise JiraToolError(page.error)
        return [
            JiraIssueSummary.model_validate(issue.model_dump())
            for page in pages
            for issue in page.issues
        ]

    @mcp.tool(annotations=_READ_ONLY)
    async def jira_search_issues_page(
        ctx: Context,
        search_input: JiraIssueSearchInput,
    ) -> list[JiraIssueSearchPage]:
        """Search Jira with paging metadata, one page per selected instance.

        Args:
            search_input: Search filters and pagination options. Use {} for the
                first page. Raw jql overrides issue_key and other filters.
                detail_level: compact requests summary only; standard includes status,
                assignee, priority, labels and components; full adds bounded description
                and selected details (no comments). Full requires max_results <= 20.
                description_limit bounds description characters (200..8000, default 2000).

        To continue, repeat the same filters with a returned instance_url and
        its next_start_at as start_at. Stop when next_start_at is null. A null
        total means unknown; an extra empty page may be needed.
        Check status/error before interpreting each page: errors are not empty results.
        complete is true only when this call contains the whole collection from offset 0,
        with no warnings or description truncation. fields_requested identifies fields
        actually fetched; compact-mode empty defaults do not prove absence. Results are
        live, so edits between requests can change offsets and totals. Do not
        interpret a partial page as a complete sprint/project report.
        """
        return await _search_pages(ctx, search_input)

    @mcp.tool(annotations=_READ_ONLY)
    async def jira_get_issue(
        ctx: Context,
        issue_key: str,
        instance_url: str = "",
    ) -> list[JiraIssue]:
        """Get details, parent, subtasks, directional links and embedded comments.

        Args:
            issue_key: Jira issue key, e.g. DEP-1.
            instance_url: Optional exact configured Jira base URL.

        Embedded comments can be incomplete: check comments_complete and use
        jira_list_comments for further pages. Null completeness means unknown.
        Parent is Jira's parent field, not a guarantee of epic membership.
        Linked issue summaries only contain fields supplied by Jira.
        """
        selected = _validated(
            JiraIssueKeyInput, "jira_get_issue", issue_key=issue_key, instance_url=instance_url
        )
        client, connectors = await _resolve_connectors(ctx, selected.instance_url)

        async def fetch(url: str, token: str) -> JiraIssue:
            raw = await jira_get(
                client,
                url,
                token,
                f"/issue/{selected.issue_key}",
                params={"fields": ",".join(_ISSUE_FIELDS)},
            )
            return parse_issue(url, raw)

        return await _collect(connectors, "jira_get_issue", fetch, missing_issue=selected.issue_key)

    @mcp.tool(annotations=_READ_ONLY)
    async def jira_list_comments(
        ctx: Context,
        issue_key: str,
        start_at: int = 0,
        max_results: int = 50,
        instance_url: str = "",
    ) -> list[JiraCommentPage]:
        """Read one page of visible comments per instance, oldest first.

        Args:
            issue_key: Jira issue key.
            start_at: Zero-based comment offset.
            max_results: Requested page size per instance, from 1 to 100.
            instance_url: Optional exact configured Jira base URL.

        Continue each instance separately using its instance_url and
        next_start_at. Stop when next_start_at is null. No comments are written.
        """
        selected = _validated(
            JiraIssueKeyInput, "jira_list_comments", issue_key=issue_key, instance_url=instance_url
        )
        page = _validated(
            JiraPageInput, "jira_list_comments", start_at=start_at, max_results=max_results
        )
        client, connectors = await _resolve_connectors(ctx, selected.instance_url)

        async def fetch(url: str, token: str) -> JiraCommentPage:
            raw = await jira_get(
                client,
                url,
                token,
                f"/issue/{selected.issue_key}/comment",
                params={
                    "startAt": page.start_at,
                    "maxResults": page.max_results,
                    "orderBy": "created",
                },
            )
            comments = [parse_comment(comment) for comment in raw["comments"]]
            return JiraCommentPage(
                **parse_page_metadata(url, raw, len(comments), page.start_at, page.max_results),
                issue_key=selected.issue_key,
                comments=comments,
            )

        return await _collect(
            connectors,
            "jira_list_comments",
            fetch,
            error_page=lambda url, error: JiraCommentPage(
                **_failed_page(url, page, error),
                issue_key=selected.issue_key,
            ),
        )

    @mcp.tool(annotations=_READ_ONLY)
    async def jira_get_issues_batch(ctx: Context, batch_input: JiraBatchInput) -> JiraBatchResult:
        """Read 1..20 keys on one Jira instance, with a result/error for each key.

        Args:
            batch_input: Keys, optional configured instance_url and description_limit.
                Instance is required when several connectors are configured. Keys are
                normalized and deduplicated in order. Descriptions are bounded to
                2000 characters by default; inspect description_truncated.

        Four requests run concurrently at most per call. Comments are excluded;
        use jira_list_comments. No automatic retry. requested_key stays unchanged
        if Jira resolves a moved issue to a new key. complete concerns requested
        keys and untruncated descriptions, not comments or a project-wide report.
        """
        client, connectors = await _resolve_connectors(
            ctx,
            batch_input.instance_url,
            "jira_get_issues_batch",
            single=True,
        )
        url, token = connectors[0]
        semaphore = asyncio.Semaphore(4)

        async def fetch(key: str) -> JiraBatchItem:
            async with semaphore:
                try:
                    raw = await jira_get(
                        client,
                        url,
                        token,
                        f"/issue/{key}",
                        params={
                            "fields": ",".join(f for f in _ISSUE_FIELDS if f != "comment"),
                        },
                    )
                    issue = parse_issue(url, raw)
                    issue.comments = []
                    issue.comments_included = False
                    issue.comments_complete = None
                    issue.comments_total = None
                    issue.description_length = len(issue.description)
                    issue.description_truncated = (
                        len(issue.description) > batch_input.description_limit
                    )
                    issue.description = issue.description[: batch_input.description_limit]
                    return JiraBatchItem(requested_key=key, status="ok", issue=issue)
                except Exception as exc:
                    return JiraBatchItem(
                        requested_key=key,
                        status="error",
                        error=upstream_error(exc, "jira_get_issues_batch", url),
                    )

        items = await asyncio.gather(*(fetch(key) for key in batch_input.issue_keys))
        failures = sum(item.status == "error" for item in items)
        truncated = any(
            item.issue is not None and item.issue.description_truncated for item in items
        )
        return JiraBatchResult(
            instance_url=url,
            items=items,
            success_count=len(items) - failures,
            failure_count=failures,
            complete=failures == 0 and not truncated,
            content_truncated=truncated,
        )

    @mcp.tool(annotations=_READ_ONLY)
    async def jira_list_boards(
        ctx: Context, board_input: JiraBoardListInput
    ) -> list[JiraBoardPage]:
        """List visible Jira Software boards, one page per selected instance.

        Args:
            board_input: Optional project key, name substring, board_type (scrum/kanban),
                instance_url, start_at and max_results. Use {} for the first page.

        Requires the Agile API. Keep each board's instance_url with its numeric ID.
        Check status/error; continue each instance with next_start_at until null.
        """
        client, connectors = await _resolve_connectors(
            ctx, board_input.instance_url, "jira_list_boards"
        )

        async def fetch(url: str, token: str) -> JiraBoardPage:
            params: dict[str, Any] = {
                "startAt": board_input.start_at,
                "maxResults": board_input.max_results,
            }
            for name, value in (
                ("projectKeyOrId", board_input.project),
                ("name", board_input.name),
                ("type", board_input.board_type),
            ):
                if value:
                    params[name] = value
            raw = await jira_get(client, url, token, "/board", params=params, api="agile")
            boards = [
                JiraBoard(instance_url=url, id=b["id"], name=b["name"], type=b["type"])
                for b in raw["values"]
            ]
            return JiraBoardPage(
                **parse_page_metadata(
                    url, raw, len(boards), board_input.start_at, board_input.max_results
                ),
                boards=boards,
            )

        return await _collect(
            connectors,
            "jira_list_boards",
            fetch,
            error_page=lambda url, error: JiraBoardPage(**_failed_page(url, board_input, error)),
        )

    @mcp.tool(annotations=_READ_ONLY)
    async def jira_list_sprints(
        ctx: Context, sprint_input: JiraSprintListInput
    ) -> list[JiraSprintPage]:
        """List sprints of a Scrum board on one selected Jira Software instance.

        Args:
            sprint_input: board_id from jira_list_boards, instance_url, optional comma-separated
                state (active,future,closed), start_at and max_results. Instance is required
                when several connectors exist. Kanban boards may not support sprints.

        Check status/error. Keep sprint ID and instance together, and follow next_start_at.
        """
        client, connectors = await _resolve_connectors(
            ctx, sprint_input.instance_url, "jira_list_sprints", single=True
        )

        async def fetch(url: str, token: str) -> JiraSprintPage:
            params: dict[str, Any] = {
                "startAt": sprint_input.start_at,
                "maxResults": sprint_input.max_results,
            }
            if sprint_input.state:
                params["state"] = sprint_input.state
            raw = await jira_get(
                client,
                url,
                token,
                f"/board/{sprint_input.board_id}/sprint",
                params=params,
                api="agile",
            )
            sprints = [
                JiraSprint(
                    instance_url=url,
                    id=s["id"],
                    name=s["name"],
                    state=s["state"],
                    goal=s.get("goal") or "",
                    start_date=s.get("startDate") or "",
                    end_date=s.get("endDate") or "",
                    complete_date=s.get("completeDate") or "",
                    origin_board_id=s.get("originBoardId"),
                )
                for s in raw["values"]
            ]
            return JiraSprintPage(
                **parse_page_metadata(
                    url, raw, len(sprints), sprint_input.start_at, sprint_input.max_results
                ),
                board_id=sprint_input.board_id,
                sprints=sprints,
            )

        return await _collect(
            connectors,
            "jira_list_sprints",
            fetch,
            error_page=lambda url, error: JiraSprintPage(
                **_failed_page(url, sprint_input, error), board_id=sprint_input.board_id
            ),
        )

    @mcp.tool(annotations=_READ_ONLY)
    async def jira_get_sprint_issues(
        ctx: Context,
        sprint_input: JiraSprintIssuesInput,
    ) -> list[JiraIssueSearchPage]:
        """Read a page of sprint issues on one selected Jira Software instance.

        Args:
            sprint_input: sprint_id from jira_list_sprints, instance_url, start_at,
                max_results, optional jql narrowing the sprint, detail_level and
                description_limit. Instance is required with several connectors.
                Full detail requires max_results <= 20; it excludes comments.

        Scope is the sprint, not the originating board's filter. Only issues visible
        to the connected account are returned. Check status/error, warnings and
        content_truncated. Follow next_start_at with the same filters until null.
        complete means the whole requested collection in this one call from offset 0.
        """
        client, connectors = await _resolve_connectors(
            ctx, sprint_input.instance_url, "jira_get_sprint_issues", single=True
        )
        fields = _search_fields(sprint_input.detail_level)
        jql = sprint_input.jql or "ORDER BY updated DESC, key ASC"

        async def fetch(url: str, token: str) -> JiraIssueSearchPage:
            raw = await jira_get(
                client,
                url,
                token,
                f"/sprint/{sprint_input.sprint_id}/issue",
                params={
                    "startAt": sprint_input.start_at,
                    "maxResults": sprint_input.max_results,
                    "jql": jql,
                    "fields": ",".join(fields),
                },
                api="agile",
            )
            return _issue_page(url, raw, sprint_input, jql, fields)

        return await _collect(
            connectors,
            "jira_get_sprint_issues",
            fetch,
            error_page=lambda url, error: JiraIssueSearchPage(
                **_failed_page(url, sprint_input, error),
                sprint_id=sprint_input.sprint_id,
                detail_level=sprint_input.detail_level,
                fields_requested=fields,
                effective_jql=jql,
            ),
        )
