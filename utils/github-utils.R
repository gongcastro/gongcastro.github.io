git_new_branch <- function(branch_name) {
    gert::git_branch_create(branch_name)
    gert::git_branch_checkout(branch_name)
    cli::cli_alert_success("Branch {.field {branch_name}} created and checked-out")
}

git_delete_branch <- function(delete_branch, checkout_branch = "main") {
    git_branch_checkout(checkout_branch)
    git_branch_delete(delete_branch)
}

quarto_push <- function(branch_name, 
                        commit_message = NULL,
                        push = TRUE,
                        pull_request = TRUE) {
    
    if (gert::git_branch_exists(branch_name)) {
        cli::cli_abort("Branch {.field {branch_name}} already exists")
    }
    
    cli::cli_progress_step("Rendering website...")
    quarto_render(as_job = FALSE, quiet = TRUE)
    
    cli::cli_progress_step("Creating new branch {.field {branch_name}}")
    usethis::pr_init(branch_name)
    
    cli::cli_progress_step(paste0("Staging files..."))
    gert::git_add(".")
    
    cli::cli_progress_step("Creating commit in {.field {branch_name}}...")
    if (is.null(commit_message)) {
        cli::cli_alert_warning("Commit message is empty")
        commit_message <- readline("Add a commit message: ")
    }
    commit_tag <- gert::git_commit(commit_message)
    
    if (push) {
        cli::cli_progress_step("Pushing to branch {.field {branch_name}}...")
        gert::git_push(verbose = FALSE)
    } else {
        cli::cli_progress_done()
    }
    
    if (push & pull_request) {
        cli::cli_progress_step("Opening PR from {.field {branch_name}} to {.field main}...")
        cli::cli_alert_info("Check {.url https://github.com/gongcastro/gongcastro.github.io}")
        usethis::pr_push()
    }
}
