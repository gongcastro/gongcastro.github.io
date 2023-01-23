gert::git_status()

quarto_push <- function(branch_name, 
                        commit_message = NULL,
                        push = TRUE,
                        pull_request = TRUE) {
    
    if (git_branch_exists(branch_name)) {
        cli_abort(paste0("Branch ", branch_name, " already exists. Specify a different name"))
    }
    
    pr_init(branch = branch_name)
    
    cli_progress_step("Rendering website...")
    quarto_render(as_job = FALSE, quiet = TRUE)
    
    cli_progress_step(paste0("Staging files..."))
    git_add(".")
    
    cli_progress_step(paste0("Creating commit", branch, "..."))
    if (is.null(commit_message)) {
        cli_alert_warning("Commit message is empty")
        commit_message <- readline("Add a commit message: \n")
    }
    commit_tag <- git_commit(commit_message)
    
    if (push) {
        cli_progress_step(paste0("Pushing to ", branch, " branch..."))
        git_push()
    } else {
        cli_progress_done()
    }
    
    if (push & pull_request) {
        usethis::pr_pull()
        gert::pu
    }
    
    
}