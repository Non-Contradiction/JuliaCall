rmd_dict = Dict()

rmd_dict["text/html"] = "function(x) cat(JuliaCall:::p_ly(x))"
rmd_dict["text/plain"] = "function(x) cat(x)"
rmd_dict["image/png"] = "function(x) cat(rmarkdown::html_notebook_output_img(bytes = x, format = 'png'))"
rmd_dict["image/jpeg"] = "function(x) cat(rmarkdown::html_notebook_output_img(bytes = x, format = 'jpeg'))"
rmd_dict["image/svg+xml"] = "function(x) cat(JuliaCall:::p_ly(x))"

rmd_display = RjuliaDisplay(rmd_dict)
