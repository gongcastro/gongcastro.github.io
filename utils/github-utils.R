gert::git_status()

quarto_push <- function(branch = "test", commit = "Update website") {
    stopifnot(git_branch_exists(branch))
    
    
    if (branch=="main") {
        cli::cli_alert_warning(paste0("Branch set to ", branch))
        continue <- usethis::ui_yeah("Do you want to continue?")
    } else {
        cli_alert_info(paste0("Rendering from branch ", branch))
    }
    
    if (!continue) {
        ui_stop("Rendering aborted")
    }
    
    
    cli_progress_step("Rendering website...")
    quarto_render()
    
    cli_progress_step(paste0("", branch, " branch..."))
    git_add("docs/")
    
    cli_progress_done()
}