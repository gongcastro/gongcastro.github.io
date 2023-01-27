# create new branch (for internal use in site_push)
git_new_branch <- function(branch_name) {
    gert::git_branch_create(branch_name)
    gert::git_branch_checkout(branch_name)
    cli::cli_alert_success("Branch {.field {branch_name}} created and checked-out")
}

# delete git branch (for internal use in site_push)
git_delete_branch <- function(delete_branch, checkout_branch = "main") {
    git_branch_checkout(checkout_branch)
    git_branch_delete(delete_branch)
    cli::cli_alert_info("Branch {.field {delete_branch}}")
}

# render site create a PR for changes in repo
site_push <- function(branch_name, 
                      commit_message = NULL,
                      push = TRUE,
                      render = TRUE,
                      pull_request = TRUE) {
    
    # abort if branch_name exists
    if (gert::git_branch_exists(branch_name)) {
        cli::cli_abort("Branch {.field {branch_name}} already exists")
    }
    
    # render site and generate new docs/
    if (render) {
        cli::cli_progress_step("Rendering website...")
        quarto_render(as_job = FALSE, quiet = TRUE)
    }
    
    # stage changes
    cli::cli_progress_step(paste0("Staging files..."))
    gert::git_add(".")
    
    # commit changes
    cli::cli_progress_step("Creating commit in {.field {branch_name}}...")
    if (is.null(commit_message)) {
        cli::cli_alert_warning("Commit message is empty")
        commit_message <- readline("Add a commit message: ")
    }
    commit_tag <- gert::git_commit(commit_message)
    cli::cli_alert_info("Commit hash: {.field {commit_tag}}...")
    
    # create new branch
    cli::cli_progress_step("Creating new branch {.field {branch_name}}")
    usethis::pr_init(branch_name)
    
    # push changes to new branch
    if (push) {
        cli::cli_progress_step("Pushing to branch {.field {branch_name}}...")
        gert::git_push(verbose = FALSE)
    } else {
        cli::cli_progress_done()
    }
    
    # push PR to GitHub repo and open browser to merge
    if (push & pull_request) {
        cli::cli_progress_step("Opening PR from {.field {branch_name}} to {.field main}...")
        cli::cli_alert_info("Check {.url https://github.com/gongcastro/gongcastro.github.io}")
        usethis::pr_push()
    }
    
    git_delete_branch(branch_name)
}
