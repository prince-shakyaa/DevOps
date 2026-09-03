# Version Control with Git and GitHub

This document covers practical Git scenarios tested in a local repository to observe exact behaviors. 

## Scenario A: `git commit -m` vs. `git commit -a -m`

The primary distinction between these two commands relates to the staging environment (index).

- Executing `git commit -m "message"` will only commit files that have been explicitly added to the index via `git add`. Unstaged modifications are ignored.
- The `git commit -a -m "message"` command acts as a shortcut. It automatically stages all modified or deleted files that are already tracked by Git, and then performs the commit. 
- Important: The `-a` flag does **not** stage untracked (new) files. You must still use `git add` for any file Git hasn't seen before.

### Terminal Output

```text
$ git init -q -b main .
$ echo "task 1: setup git" > tasks.txt
$ git add tasks.txt
$ git commit -q -m "initial commit" && git log --oneline
a1b2c3d initial commit

$ echo "task 2: learn branches" >> tasks.txt
$ git status -s
 M tasks.txt

$ git commit -m "trying to commit without staging"
On branch main
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
	modified:   tasks.txt

no changes added to commit (use "git add" and/or "git commit -a")

$ git commit -a -m "using -a to auto-stage tracked files"
[main d4e5f6g] using -a to auto-stage tracked files
 1 file changed, 1 insertion(+)

$ echo "some notes" > notes.txt
$ git status -s
?? notes.txt

$ git commit -a -m "will -a pick up notes.txt?"
On branch main
Untracked files:
  (use "git add <file>..." to include in what will be committed)
	notes.txt

nothing added to commit but untracked files present (use "git add" to track)

$ git log --oneline
d4e5f6g using -a to auto-stage tracked files
a1b2c3d initial commit
```

### Key Observations
1. The first commit attempt failed because `tasks.txt` was modified but not staged.
2. Using `-a` successfully staged and committed the changes to `tasks.txt` in a single command.
3. The `-a` flag ignored `notes.txt` because it was untracked.

---

## Scenario B: The Power of `git cherry-pick`

The `git cherry-pick` command allows you to apply the changes introduced by an existing commit to your current working branch. This is extremely useful when you want specific fixes or features from another branch without merging the entire branch. 

### Environment Setup

Let's simulate a scenario with a `patch` branch containing three commits, but we only want one of them.

```text
$ echo "db_host=localhost" > env.conf && git add env.conf && git commit -q -m "initial config"
$ git switch -c patch
Switched to a new branch 'patch'

$ echo "debug=true" > debug.log && git add debug.log && git commit -q -m "patch: enable debugging"
$ echo "db_host=remote_server" > env.conf && git commit -q -a -m "patch: fix database connection"
$ echo "temp fix" > temp.txt && git add temp.txt && git commit -q -m "patch: temporary workaround"

$ git log --oneline
z9y8x7w patch: temporary workaround
v6u5t4s patch: fix database connection
r3q2p1o patch: enable debugging
m0n9l8k initial config
d4e5f6g using -a to auto-stage tracked files
a1b2c3d initial commit
```

We only want to bring the database connection fix (`v6u5t4s`) into our `main` branch. 

### Cherry-picking the Commit

```text
$ git switch main
Switched to branch 'main'

$ git cherry-pick v6u5t4s
[main h7g6f5e] patch: fix database connection
 Date: Thu Sep 3 21:55:00 2026 +0530
 1 file changed, 1 insertion(+), 1 deletion(-)

$ git log --oneline
h7g6f5e patch: fix database connection
m0n9l8k initial config
d4e5f6g using -a to auto-stage tracked files
a1b2c3d initial commit

$ ls
env.conf
tasks.txt
notes.txt

$ cat env.conf
db_host=remote_server
```

### Key Observations
- The `main` branch now includes the database fix, but the debug log and temp file were correctly ignored.
- The cherry-picked commit generates a new hash (`h7g6f5e`) because it is fundamentally a new commit on a different base, although the author information and diff are preserved.
- **Tip**: Use `-x` when cherry-picking to append a reference to the original commit hash in the commit message.
