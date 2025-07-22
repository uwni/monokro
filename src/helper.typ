#let caption-env(config) = body => {
  set text(size: 0.8 * 11pt, style: "normal", weight: "regular", font: config._caption_font)
  set par(spacing: 1.2em, leading: 0.5em, hanging-indent: 0pt)
  body
}

#let italic(config) = if "_italic_font" in config { text.with(font: config._italic_font, style: "italic") } else {
  text.with(style: "italic")
}
