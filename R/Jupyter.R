html_wrap <- function(x) paste('<html>', x, '</html>')
p_ly <- function(x)
    sub('<script.*plotly-latest.min.js\">',
        '<script src="https://cdn.plot.ly/plotly-latest.min.js">',
        x)
