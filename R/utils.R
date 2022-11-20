build <- function(){
    blogdown::build_site()
    blogdown::serve_site()
    unlink("docs", recursive = TRUE)
    shell("rename public docs")
}

publish <- function(branch_name, files = "docs/", commit_message = "Update website") {
    build()
    gert::git_add(files = files)
    gert::git_commit(commit_message)
    usethis::pr_init(branch_name)
    usethis::pr_push()
}