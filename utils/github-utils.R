git_new_branch <- function(branch_name) {
    gert::git_branch_create(branch_name)
    gert::git_branch_checkout(branch_name)
    cli::cli_alert_success("Branch {.field {branch_name}} created and checked-out")
}

quarto_push <- function(branch_name, 
                        commit_message = NULL,
                        push = TRUE,
                        pull_request = TRUE) {
    
    cli::cli_progress_step("Rendering website...")
    quarto_render(as_job = FALSE, quiet = TRUE)
    
    cli::cli_progress_step(paste0("Staging files..."))
    gert::git_add(".")
    
    cli::cli_progress_step(paste0("Creating commit", branch, "..."))
    if (is.null(commit_message)) {
        cli::cli_alert_warning("Commit message is empty")
        commit_message <- readline("Add a commit message: \n")
    }
    commit_tag <- gert::git_commit(commit_message)
    
    if (push) {
        cli::cli_progress_step(paste0("Pushing to ", branch, " branch..."))
        gert::git_push()
    } else {
        cli::cli_progress_done()
    }
    
    if (push & pull_request) {
        usethis::pr_push()
    }
    
    
}