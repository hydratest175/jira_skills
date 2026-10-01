APPLICABLE TOOLS
jira_search_issues_page, jira_list_boards, jira_list_sprints,
jira_get_sprint_issues.

DEFINE THE SCOPE
- Prefer jira_search_issues_page over jira_search_issues because it exposes
  the metadata required to manage pagination.
- Reuse known identifiers; otherwise resolve the project or board.
- Keep instance_url together with board and sprint identifiers.
- For an unknown sprint, use jira_list_boards and jira_list_sprints before
  jira_get_sprint_issues.
- Do not assume a project has only one board or one active sprint.

BUILD THE SEARCH
- Follow the tool's input schema:
  search_input, board_input, or sprint_input as applicable.
- Filter as closely as possible to the request: project, status, assignee,
  component, labels, issue type, or date range.
- In jira_search_issues_page, jql overrides the other search filters.
  When providing jql, include all required constraints in that expression.
- Inspect effective_jql in the response.
- For a complete traversal using JQL, use a stable ordering such as
  ORDER BY key ASC when appropriate. Results can still change during collection.
- Do not map a team to a component unless that mapping is established.

SELECT THE DETAIL LEVEL
- compact: identify issues by key and summary.
- standard: analyze status, assignee, priority, labels, and components.
- full: retrieve bounded descriptions and additional details, without comments.
- With full, max_results must be 20 or less.
- Inspect fields_requested. A field not requested may have an empty default
  without actually being empty in Jira.
- Select standard directly when the request requires status or assignment
  statistics.

TRAVERSE PAGES
1. Start with start_at=0 and an appropriate page size, up to 100.
2. Inspect status and error for each instance before interpreting its results.
3. Pass next_start_at as start_at, preserving that instance_url and all filters.
4. For an exhaustive request, continue until next_start_at is null.
5. Deduplicate issues by instance_url and issue key.

- total=null means the total is unknown.
- Do not infer the total from the number of issues in a single page.
- complete describes one call's result, not all accumulated pages.
  The final page can therefore have complete=false.
- Evaluate page coverage separately from warnings and content_truncated.
- If the cursor stops advancing, stop and report the pagination anomaly.
- If an error or execution limit interrupts collection, retain the successful
  results and identify the missing scope.

INTERPRET RESULTS
- For an exact count, retrieve all required pages.
- For a request for a few matching issues, stop when the request is satisfied;
  do not present global statistics based on that subset.
- A complete collection covers only resources visible to the connected
  account and matching the filters.
- The current issues in a sprint do not automatically represent the sprint's
  historical state at closure.

EXAMPLE ARGUMENTS FOR jira_search_issues_page
{
  "search_input": {
    "jql": "project = DEMO AND statusCategory != Done ORDER BY key ASC",
    "detail_level": "standard",
    "start_at": 0,
    "max_results": 50
  }
}

For continuation, preserve this JQL and use the returned instance_url
and next_start_at.













APPLICABLE TOOLS
jira_get_issue, jira_get_issues_batch, jira_list_comments.

SELECT THE TOOL
- For one specific issue, use jira_get_issue.
- For several known keys on the same instance, prefer jira_get_issues_batch
  over a sequence of individual calls.
- Limit each batch to 20 keys.
- Group keys by instance before making batch calls.
- When multiple connectors are configured, explicitly provide instance_url
  for the batch.
- Use jira_list_comments when comments are needed.

INTERPRET A BATCH
- Inspect the status of every element in items.
- An individual failure does not invalidate successfully retrieved issues.
- Use requested_key to match a result to the original request.
  Jira may return a different key for a moved issue.
- The batch excludes comments: comments=[] does not mean no comments exist.
- complete concerns the requested keys and untruncated descriptions.
  It does not guarantee complete comments or project-wide coverage.

DESCRIPTIONS
- Batch descriptions are limited to 2,000 characters by default.
- Inspect description_truncated and description_length.
- If the missing portion matters, increase description_limit up to 8,000,
  or use jira_get_issue for the affected issues only.
- Avoid additional detail calls when the necessary information is already
  available.

COMMENTS
- In jira_get_issue, inspect comments_included, comments_total,
  and comments_complete.
- comments_complete=null means completeness is unknown.
- To retrieve more comments, use jira_list_comments and follow
  next_start_at separately for each instance.
- Comments are returned from oldest to newest. The first page does not
  necessarily contain the latest decision.
- Before answering about a recent discussion, retrieve the relevant
  comments rather than relying only on the initial page.

HIERARCHY AND DEPENDENCIES
- parent represents Jira's parent field. Do not automatically interpret it
  as epic membership.
- For links, interpret direction, relationship, and the linked issue together.
- Do not reverse "blocks" and "is blocked by".
- Linked issues are summaries. Retrieve their details if their state or
  context is necessary to answer the question.

EXAMPLE ARGUMENTS FOR jira_get_issues_batch
{
  "batch_input": {
    "issue_keys": ["DEMO-12", "DEMO-18"],
    "description_limit": 4000
  }
}

Add instance_url to batch_input once the instance is known.
It is required when multiple connectors are configured.














IDENTIFY RESOURCES
- Resolve an unknown project with gitlab_list_projects(search=...).
- Preserve instance_url, path_with_namespace, and id.
- Provide an unencoded project path or an ID accepted by the tool schema.
- Do not pass group/project!42 as a project path:
  project and mr_iid are separate parameters.
- Once the instance is identified, provide instance_url to avoid querying
  every connector unnecessarily.
- membership=true selects projects the account is a member of.
  membership=false searches all projects visible to the account.
  Select and describe the scope that matches the request.

READ RESPONSE ENVELOPES
- Tools return a list of envelopes, one per connector.
  MCP may expose this under structuredContent.result;
  some clients already unwrap it.
- Business objects are in items within each envelope.
- Inspect error and warnings even when items contains data.
- An envelope can contain successful pages followed by an error.
- Distinguish collection_complete, which concerns collection coverage,
  from content_complete, which concerns returned content.
- Inspect omitted_fields and truncated_fields on individual objects.
- An omitted field in a compact response does not indicate absence.
- Failures can also be exposed as MCP tool-call errors.

COLLECT EFFICIENTLY
- Use detail=compact for lists when the parameter is available.
- Use detail tools or detail=full when their additional content is needed.
- Apply filters before paginating.
- per_page is limited to 100 and max_pages to 5 per instance per call.
- max_pages retrieves several pages without another model decision.
  Use it when the expected volume warrants it.

CONTINUE PAGINATION
1. Inspect pagination.next_page.
2. When more data is required, pass it as page while preserving the instance,
   filters, and per_page.
3. Continue when next_page exists, even if has_more is null.
4. Deduplicate objects by instance, project, and identifier.
5. Stop at a confirmed end or an explicit limit.

- A missing total is unknown, not zero.
- collection_complete=false on a continuation call does not require a restart:
  that call does not include earlier pages.
- For an ordinary list, assess coverage across all successful pages from
  the first page through the confirmed end.
- Diffs and comparisons have additional limitations:
  apply gitlab_changes_and_discussions.
- Never repeatedly request a cursor that does not advance.

HANDLE LIMITS
- Do not interpret 404 as proof of nonexistence:
  the resource may be inaccessible or the endpoint unavailable.
- After an error with partial results, resume the indicated page when
  the error is recoverable and the execution budget permits.
- If a response requires reducing per_page, do not blindly reuse the same
  page number: changing page size changes offsets.
  Restart with the smaller page size and deduplicate.
- Do not claim an exhaustive collection if an instance failed.













APPLICABLE TOOLS
gitlab_list_repository_tree, gitlab_get_file, gitlab_get_job_log.
To identify a job: gitlab_get_pipeline and gitlab_list_pipeline_jobs.

LOCATE THE CONTENT
- For an unknown file, explore the repository tree using a targeted path.
- Do not recursively traverse the entire repository when one directory
  is sufficient.
- For logs, identify the exact pipeline and job.
- Inspect failure_reason and allow_failure in job results before deciding
  which logs to read.
- For a pipeline originating from a fork, use its project_id when provided
  to query the correct project.

READ THE WINDOW
- Text is located in items[i].window.content.
- start_line is 1-based.
- start_column is a 0-based character offset.
- Inspect window.has_more, omitted_before, and truncated.
- has_more=false does not mean the entire content has been read when
  omitted_before=true.

FILES
- An empty ref uses HEAD.
- To continue reading the same revision, use the returned commit_id as ref.
- Do not substitute last_commit_id for commit_id:
  the last commit that changed the file is not necessarily the revision
  being inspected.
- Pass window.next_line as start_line and window.next_column as start_column.
- Do not simply add 1 to end_line: a long line may have been cut midway.
- Preserve the project, file path, and instance.

LOGS
- The default behavior returns a window over the last 200 lines.
- To read from the beginning or resume at an explicit position,
  set tail_lines=0.
- Use both window cursors for continuation.
- If the end of a log contains only the final failure message, inspect
  earlier lines that explain the error.
- Logs of running jobs can change between calls.

LIMITS
- max_lines limits lines; max_chars limits characters.
  Whichever limit is reached first can end the excerpt.
- These windows reduce the text returned to the model, but do not
  necessarily reduce the initial HTTP download.
- Responses exceeding the transport limit can fail even for small windows.
  Do not keep retrying by reducing only max_lines.
- Binary or non-UTF-8 files may be explicitly rejected.
- Do not infer missing content or invent a diagnosis from an unavailable log.

EXAMPLE INITIAL FILE READ
gitlab_get_file arguments:
{
  "project": "group/demo",
  "file_path": "src/main.py",
  "ref": "main",
  "start_line": 1,
  "max_lines": 100
}

For continuation, use the actual returned commit_id and window cursors.














APPLICABLE TOOLS
gitlab_get_merge_request, gitlab_get_merge_request_diff,
gitlab_list_merge_request_discussions, gitlab_list_merge_request_pipelines,
gitlab_compare_refs.

MERGE REQUEST CONTEXT
- Read the MR details before interpreting its changes.
- Preserve the project, instance, and mr_iid.
- Retrieve discussions, diffs, and pipelines as needed rather than
  automatically calling every related tool.

MR DIFFS
- gitlab_get_merge_request_diff returns diff objects in items.
- Follow pagination.next_page for additional files.
- max_text_chars limits each diff; inspect truncated_fields.
- Inspect collapsed, too_large, and diff_complete.
- An empty diff may represent a binary file or a limitation.
- Increasing max_text_chars can resolve local truncation, but cannot
  recover content omitted by GitLab.
- Reaching the end of pagination does not guarantee an exhaustive review:
  collection_complete may remain false because of upstream limitations.
- When necessary, read files at the relevant SHAs. Do not substitute
  current branch content for a historical revision.

DISCUSSIONS: TWO CONTINUATION LEVELS
- page/per_page paginate discussions, not individual notes.
- A discussion can itself contain only a subset of its notes.
- To retrieve the remaining notes, pass its id as discussion_id and
  next_note_offset as note_offset.
- Continue until next_note_offset is null when all notes are required.
- Separately inspect note-text truncation and max_text_chars.
- has_unresolved_notes indicates unresolved notes exist; read the relevant
  notes before explaining their content.
- Distinguish ordinary comments, resolvable discussions, and actual
  merge blockers reported by MR metadata.

REFERENCE COMPARISONS
- Use from_ref as the source and to_ref as the destination.
- straight=true compares the two references directly.
- straight=false compares from their merge base.
- Select the mode that matches the question and state which was used.
- Before continuation calls, use two verified SHAs rather than branches
  that may change.
- Commits and files have separate cursors:
  next_commit_offset maps to commit_offset;
  next_file_offset maps to file_offset.
- Track the two collections separately and deduplicate items returned again
  by subsequent calls.
- Offsets slice data returned by GitLab; they do not bypass GitLab's limits.
- Inspect compare_timeout and upstream_diff_completeness.
- returned_commits_total and returned_files_total describe what GitLab
  returned, not a guarantee that every change was available.
- Use detail=full when the additional text exposed by the schema is needed,
  then inspect truncation indicators.

INTERPRET FIELDS
- An assigned reviewer does not prove approval was granted.
- A merged MR proves integration into its target branch, not deployment.
- A successful pipeline does not guarantee all functional acceptance
  criteria were tested or that deployment occurred.
- null means unknown. Do not implicitly convert it to false or to
  the absence of a blocker.














APPLICABLE TOOLS
gitlab_list_pipelines, gitlab_get_pipeline, gitlab_list_pipeline_jobs,
gitlab_get_job_log.
Use gitlab_list_projects only to resolve a project explicitly identified
by the user or established in the conversation.

RESOLVE THE SCOPE BEFORE CALLING TOOLS
- Reuse the project and instance already established in the conversation
  when the request clearly refers to them.
- If the user provides a project name, resolve it with a targeted
  gitlab_list_projects(search=...) call when necessary.
- If neither the request nor the conversation identifies a project,
  ask which project or bounded set of projects to inspect.
- Do not interpret "list failed pipelines" as "search every accessible project".
- Do not call gitlab_list_projects with an empty search merely to discover
  where failed pipelines might exist.
- The deployed tool set has no global cross-project pipeline search.
  Do not simulate one by silently enumerating all accessible projects.

DEFAULT REQUEST
For a simple request to list failed pipelines in an identified project:
- Call gitlab_list_pipelines with:
  project=<resolved project>,
  instance_url=<resolved instance>,
  status="failed",
  per_page=10,
  max_pages=1.
- Add ref only when the user specifies a branch or reference,
  or the conversation clearly establishes one.
- Use only parameters exposed by the actual tool schema.
- Return a concise list of pipeline IDs, references, statuses,
  available timestamps, and links.
- State that the response is a bounded list when more pages exist.
- Do not fetch each pipeline's details, jobs, or logs merely to list failures.
- Do not repeat the same list request if it has already returned the
  information needed for this answer.

MULTI-PROJECT REQUESTS
Use these default operational limits for pipeline discovery:
- At most 3 explicitly identified projects per batch.
- At most 10 pipeline records per project.
- max_pages=1 for each initial pipeline-list call.
- At most 5 tool calls for project resolution and pipeline listing combined.
- If parallel execution is supported, at most 2 independent list calls
  concurrently.

These are request budgets, not limits to reset after every tool call.
If the configured runtime imposes stricter limits, follow those limits.

- Never expand the batch automatically to other projects.
- If the user requests a broader inventory, explain that it requires
  project-by-project retrieval and propose bounded batches.
- For "all my projects", ask the user to select a project set or confirm
  a bounded batch before enumerating projects.
- Return the current batch's results and coverage before starting another.
- Do not present a batch as the complete cross-project inventory.
- Do not claim a global "latest failures" ranking without sufficient
  coverage across the requested projects.

PAGINATION
- Apply gitlab_results_and_pagination to inspect envelopes and errors.
- Continue pagination only when requested or required by the explicit task,
  and only within the current operational budget.
- Preserve the project, instance, filters, and per_page when resuming.
- Use pagination.next_page rather than guessing the next page.
- When the budget is reached, return collected results with the remaining
  scope and continuation point. Do not discard successful results.
- Never restart discovery from the project list just to continue a known
  project's pipelines.

DIAGNOSE ONLY WHEN REQUESTED
- Listing failed pipelines does not require diagnosing them.
- If the user asks why a specific pipeline failed:
  1. Read gitlab_get_pipeline if its details are needed.
  2. Call gitlab_list_pipeline_jobs with scope="failed".
  3. Inspect failure_reason and allow_failure.
  4. Read only the relevant job logs.
- If several pipelines are listed and the user asks for an unspecified
  diagnosis, clarify which pipeline or propose one explicit candidate.
- Do not automatically download logs for every failed pipeline.
- If no matching pipelines are returned, report that result within the
  queried scope. Do not broaden the search to other projects.

EXAMPLES
User: "List failed pipelines."
No project established:
Ask: "Which GitLab project should I check?"

User: "List failed pipelines."
Project group/demo already established:
Call gitlab_list_pipelines for group/demo with status="failed",
per_page=10 and max_pages=1.

User: "Why did pipeline 123 fail in group/demo?"
Inspect that pipeline and its failed jobs; do not enumerate projects.

User: "List failures across all my projects."
Explain that this requires per-project calls and ask for a bounded
project selection or confirmation of an initial batch.