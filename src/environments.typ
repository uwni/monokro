#import "components.typ": * // import components
#import "helper.typ": * // import helper functions

#let _env_state = state("env", (:))

#let _reset_env_counting() = _env_state.update(it => it.keys().map(k => (k, 0)).to-dict())


#let accent-frame-heading(config, it) = {
  set text(
    font: config._sans_font,
    weight: 500,
    tracking: 0.07em,
    size: config._main_size,
    fill: config._color_palette.accent,
  )
  box(it)
}

#let accent-frame(config) = (
  fill: config._color_palette.grey-light,
  width: 100%,
  outset: 0pt,
  inset: 1em,
  breakable: true,
)

#let example-heading(config, it) = {
  set text(
    font: config._sans_font,
    weight: 500,
    tracking: 0.07em,
    size: config._main_size,
    fill: config._color_palette.accent,
  )
  block(
    it,
    spacing: 1em,
    sticky: true,
    stroke: (top: gradient.linear(config._color_palette.accent, white)),
    outset: (x: 1em, top: 1em),
  )
}


#let example-bottomdeco(config) = {
  block(height: 1pt, width: 1em, fill: config._color_palette.accent, outset: 0pt, above: 0pt, breakable: false)
  v(config._envskip, weak: true)
}

#let solid-frame(config) = (
  stroke: (left: (thickness: .25em, paint: config._color_palette.accent)),
  width: 100%,
  outset: (bottom: 1pt, top: 0.5pt),
  inset: 1em,
  breakable: true,
)

#let plain-frame-heading(it) = {
  text(style: "italic", it)
}

#let plain-frame(config) = {
  (width: 100%)
}

#let environment(
  config,
  kind,
  topdeco: config => { v(config._envskip, weak: true) },
  bottomdeco: config => { v(config._envskip, weak: true) },
  frame,
  heading,
  title,
  body,
  label: none,
  numbered: true,
) = [
  #_env_state.update(it => it + (str(kind): it.at(kind, default: 0) + 1))
  #show figure.where(kind: kind): set block(breakable: true)
  #show figure.where(kind: kind): it => it.body

  #let i18n = config.i18n.at(kind)
  #let (name, supplement) = if type(i18n) == dictionary {
    (i18n.name, i18n.supplement)
  } else if type(i18n) == str {
    (i18n, i18n)
  } else { panic("Invalid i18n entry for kind: " + kind) }
  #figure(kind: kind, supplement: supplement, placement: none, caption: none, {
    set align(left)
    topdeco(config)
    block(breakable: true, ..frame(config), [
      #heading(if numbered {
        // set text(fill: config._color_palette.grey)
        let num = context [#current_chapter().index.at(0).#_env_state.get().at(kind)]
        name + h(.25em) + num + h(.5em) + title
      } else {
        name + h(.5em) + title
      })
      #body
    ])
    bottomdeco(config)
  }) #label
]


#let _remark(config, ..args) = environment(
  config,
  "remark",
  red-frame,
  red-frame-heading.with(config),
  none,
  ..args,
)

#let _example(config, title: none, ..args) = environment(
  config,
  "example",
  solid-frame,
  example-heading.with(config),
  bottomdeco: example-bottomdeco,
  topdeco: config => { v(config._envskip, weak: true) },
  title,
  ..args,
)

#let _proposition(config, title: none, body, ..args) = environment(
  config,
  "proposition",
  accent-frame,
  accent-frame-heading.with(config),
  if title != none { [: #title] + h(1fr) },
  body,
  ..args,
)

#let _highlighteq(config, body) = {
  $
    #box(stroke: config._color_palette.grey, inset: 1em, body)
  $
}

#let _definition(config, title: none, body, ..args) = environment(
  config,
  "definition",
  accent-frame,
  accent-frame-heading.with(config),
  if title != none { [: #title] + h(1fr) },
  body,
  ..args,
)

#let _proof(config, title: none, body) = {
  let title = if title != none [(#title)]
  let qed_symbol = text(config._color_palette.accent, config._qed_symbol)
  let _body = {
    title + body + h(1fr) + qed_symbol
  }
  if "children" in body.fields() {
    let children = body.children
    let last = children.pop()
    if last.func() == math.equation {
      let with_qed = grid(
        columns: (1fr, auto, 1fr),
        none, last, align(right + horizon, qed_symbol),
      )
      // let with_qed = last + place(right + bottom, text(config._color_palette.accent, config._qed_symbol))
      children.push(with_qed)
      _body = [].func()(title + children)
    }
  }
  environment(
    config,
    numbered: false,
    "proof",
    plain-frame,
    plain-frame-heading,
    none,
    _body,
  )
}
