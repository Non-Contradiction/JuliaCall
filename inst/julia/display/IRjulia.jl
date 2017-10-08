irjulia_dict = Dict()

irjulia_dict["application/json"] = "IRdisplay::display_json"
irjulia_dict["application/javascript"] = "IRdisplay::display_javascript"
irjulia_dict["text/html"] = "IRdisplay::display_html"
irjulia_dict["text/plain"] = "IRdisplay::display_html"
irjulia_dict["text/markdown"] =  "IRdisplay::display_markdown"
irjulia_dict["text/latex"] = "IRdisplay::display_latex"
irjulia_dict["image/png"] = "function(x) IRdisplay::display_png(charToRaw(x))"
irjulia_dict["image/jpeg"] = "function(x) IRdisplay::display_jpeg(charToRaw(x))"
irjulia_dict["application/pdf"] = "function(x) IRdisplay::display_pdf(charToRaw(x))"
irjulia_dict["image/svg+xml"] = "IRdisplay::display_svg"

irjulia_display = RjuliaDisplay(irjulia_dict)
