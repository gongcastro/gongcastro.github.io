source("renv/activate.R")
# REMEMBER to restart R after you modify and save this file!

library(blogdown)

if (!("usethis" %in% rownames(installed.packages()))) {
    renv::update()
}

# First, execute the global .Rprofile if it exists. You may configure blogdown
# options there, too, so they apply to any blogdown projects. Feel free to
# ignore this part if it sounds too complicated to you.
if (file.exists("~/.Rprofile")) {
  base::sys.source("~/.Rprofile", envir = environment())
}

# Now set options to customize the behavior of blogdown for this project. Below
# are a few sample options; for more options, see
# https://bookdown.org/yihui/blogdown/global-options.html
options(
    # blogdown options
  blogdown.serve_site.startup = FALSE, # to automatically serve the site on RStudio startup, set this option to TRUE
  blogdown.knit.on_save = TRUE, # to disable knitting Rmd files on save, set this option to FALSE
  blogdown.method = 'html', # build .Rmd to .html (via Pandoc); to build to Markdown, set this option to 'markdown'
  blogdown.hugo.version = "0.80.0", # fix Hugo version
 
  # usethis options
  usethis.full_name = "Gonzalo García-Castro",
  usethis.protocol  = "ssh",
  usethis.description = list(
      "Authors@R" = utils::person(
          "Gonzalo", "García-Castro",
          email = "gonzalo.garciadecastro@upf.edu",
          role = c("aut", "cre"),
          comment = c(ORCID = "0000-0002-8553-4209")
      ),
      Version = "0.0.0.9000"
  ),
  usethis.destdir = "~/Documents/",
  usethis.overwrite = TRUE,
  
  # browsing options
  browser = "C:/Program Files/Google/Chrome/Application/chrome.exe"
)

usethis::ui_info("See .Rprofile for consulting available functions")
