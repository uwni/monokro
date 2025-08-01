#import "components.typ": *
#import "index.typ": use_word_list
#import "environments.typ": _env_state, _reset_env_counting
#import "helper.typ": caption-env, italic
/// text properties for the main body
#let _pre_chapter() = {
  counter(math.equation).update(0)
  counter(figure.where(kind: table)).update(0)
  counter(figure.where(kind: image)).update(0)
  counter(figure.where(kind: raw)).update(0)
  _reset_env_counting()
  justify-page()
}

#let preamble(body) = {
  set page(numbering: "I")
  set heading(
    numbering: none,
    supplement: none,
    depth: 1,
  )
  body
}

#let page-number(config, offset: 0pt) = context {
  let number = text(config._page_num_size, font: config._sans_font, weight: "semibold", current_page())

  if is_even_page() [
    #h(-offset)#number#h(1fr)
  ] else [
    #h(1fr)#number#h(-offset)
  ]
}

#let template(
  config,
  title,
  author,
  date,
  draft,
  two-sided,
  chap-imgs,
  body,
) = {
  ///utilities
  let sans = text.with(font: config._sans_font)
  let semi = text.with(weight: "semibold")

  /// Set the document's basic properties.
  let author_en = if type(author) == dictionary {
    author.at("en")
  } else if type(author) == string {
    author
  } else if type(author) == array {
    author.at(0)
  } else {
    panic("cannot resolve author info")
  }

  set document(title: title.at(config._lang), author: author_en, date: date)

  set page(
    // explicitly set the paper
    paper: config._paper,
    header: context if not is_starting() and current_chapter() != none {
      let (index: (chap_idx, sect_idx), body: (chap, sect)) = current_chapter()
      let chap_prefix = upper[
        #if chap_idx > 0 [
          #chap_idx. #h(1em, weak: true)
        ]
        #chap
      ]
      let sect_prefix = upper[
        #if sect_idx != none and sect_idx > 0 {
          [#numbering("1.1", chap_idx, sect_idx) #h(1em, weak: true)]
          sect
        }
      ]

      set text(font: config._sans_font)

      let page_num = semi(config._page_num_size, current_page())

      if two-sided and is_even_page() [
        #h(-config._page_margin_sep)#box(width: config._page_margin_sep, page_num)#chap_prefix
      ] else [
        #set align(right)
        #sect_prefix #box(width: config._page_margin_sep, page_num) #h(-config._page_margin_sep)
      ]
    },
    footer: context if is_starting() {
      page-number(config, offset: config._page_margin_sep)
    },
    margin: (
      top: config._page_top_margin,
      bottom: config._page_bottom_margin,
      outside: config._page_margin + config._page_margin_sep,
      inside: config._page_margin,
    ),
    footer-descent: 30% + 0pt, // default
    header-ascent: 30% + 0pt, // default
    numbering: "1",
  )

  counter(page).update(1)

  // set the font for main texts
  set text(
    size: config._main_size,
    font: config._serif_font,
    weight: config._default_weight,
    lang: config._lang,
  )

  set text(_region) if "_region" in config

  /*-- Math Related --*/
  set math.equation(numbering: (..num) => numbering("(1.1.a)", counter(heading).get().first(), ..num))
  set math.equation(supplement: config.i18n.equation) if "i18n" in config and "equation" in config.i18n

  show math.equation: set text(..config._math_text_opts)
  show math.equation: set block(spacing: config._eq_spacing)
  show math.equation: it => {
    if it.block {
      let eq = if it.has("label") { it } else [
        #counter(math.equation).update(v => if v == 0 { 0 } else { v - 1 })
        #math.equation(it.body, block: true, numbering: none)#label("")
      ]
      eq
    } else {
      it
    }
  }
  set math.cases(gap: config._lineskip)


  // set paragraph style
  set par(leading: config._lineskip, spacing: config._parskip, first-line-indent: 1em, justify: true)
  show raw: set text(font: config._mono_font, weight: "regular")

  show figure.caption: set text(font: config._caption_font) if "_caption_font" in config

  set heading(numbering: "1.1")
  set heading(supplement: it => if it.depth == 1 { config.i18n.chapter } else { config.i18n.section }) if (
    "i18n" in config and "section" in config.i18n and "chapter" in config.i18n
  )
  set heading(supplement: config._chapter) if "_chapter" in config

  show heading.where(level: 1): it => {
    _pre_chapter()
    _standalone_heading(
      config,
      it,
    )
  }

  show heading.where(level: 2): it => block(spacing: 1.5em, above: 3em, width: 100%, {
    set text(config._heading2_size, weight: "bold", font: config._sans_font, fill: config._color_palette.accent)
    let num = if it.numbering != none { text(counter(heading).display(it.numbering)) } else { [○] }
    grid(
      columns: (auto, 1fr),
      column-gutter: 1em,
      num, it.body,
    )
  })

  show heading.where(level: 3): it => {
    show: block.with(above: 1.5em, below: 1em)
    set text(
      weight: 500,
      size: config._heading3_size,
      font: config._sans_font,
      fill: config._color_palette.grey,
      tracking: 0.07em,
    )
    upper(it.body)
  }

  set bibliography(title: config.i18n.bibliography) if "i18n" in config and "bibliography" in config.i18n
  show bibliography: it => {
    justify-page()
    it
  }

  /*-- emph --*/
  show emph: italic(config)
  // show strong: set text(_color_palette.accent)

  /// Main body.
  body
}

#let _outline(config, ..args) = {
  set outline(indent: auto, depth: 2)
  set outline(title: config._toc) if "toc" in config

  set page(
    header: none,
    footer: page-number(config, offset: config._page_margin_sep),
    numbering: "I",
  )
  set par(leading: 1em, spacing: 0.5em)

  show outline.entry.where(level: 1): it => {
    set text(font: config._sans_font, weight: "bold", fill: config._color_palette.accent)
    set block(above: 1.25em)
    let prefix = if it.element.numbering == none { none } else if config._lang == "zh" {
      it.element.supplement + it.prefix()
    }
    let body = upper(it.body() + h(1fr) + it.page())
    link(it.element.location(), it.indented(prefix, body))
  }
  _toc_heading(config, heading(outlined: false, numbering: none, config.i18n.toc, depth: 1))
  columns(2, [#outline(..args, title: none)#v(1pt)])
}

#let mainbody(config, body, two-sided, chap-imgs) = {
  // make sure the page is start at right
  justify-page()
  let sans = text.with(font: config._sans_font)

  set page(
    numbering: "1", // setup margins:
  )

  show heading.where(level: 1): it => {
    _pre_chapter()
    styled-heading(
      config,
      it,
    )

    // marginalia leaves a blank space here. therefore, we need to
    // eliminate the space.
    h(0pt, weak: true)
  }

  /* ---- Customization of Table&Image ---- */
  set figure(gap: 0pt, numbering: (..num) => numbering("1.1", counter(heading).get().first(), num.pos().first()))
  show figure.where(kind: image): set block(spacing: config._figure_spacing, breakable: false)
  show figure.where(kind: table): set block(spacing: config._figure_spacing, breakable: false)

  set figure.caption(position: top, separator: sym.space)
  show figure.caption: it => [
    #show: caption-env(config)
    #box(
      sans(weight: "medium")[
        #it.supplement
        #context counter(figure.where(kind: it.kind)).display()
      ]
        + it.separator,
    )
    #it.body
  ]

  show figure: it => if it.kind == image {
    layout(((width, height)) => {
      let (width: f_width, height: f_height) = measure(width: width, height: height, it.body)
      let overheight = 2 * f_height > height
      let overwidth = 2 * f_width > width

      grid(
        columns: 2,
        column-gutter: 1em,
        align: bottom,
        it.body, it.caption,
      )
    })
  } else { it }

  set table(stroke: none, align: horizon + center)
  show figure.where(kind: table): set figure(supplement: config._i18n.table) if (
    "_i18n" in config and "table" in _i18n
  )
  show figure.where(kind: image): set figure(supplement: config._i18n.figure) if (
    "_i18n" in config and "figure" in _i18n
  )

  // reset the counter for the main body
  counter(page).update(1)
  counter(heading).update(0)
  body
}


// TODO: specify the appendix heading
#let appendix(config, body) = {
  justify-page()

  context {
    let offset = counter(heading).get().first()
    set heading(supplement: config.i18n.appendix, numbering: (..num) => numbering(config._appendix_numbering, ..{
      let num = num.pos()
      (num.remove(0) - offset, ..num)
    }))
    pagebreak()
    show heading.where(level: 1): it => {
      _pre_chapter()
      _appendix_heading(
        config,
        it,
      )
    }

    body
  }
}

#let subheading(config, body) = {
  set par(leading: 0.5em)
  v(0pt, weak: true)
  block(text(font: config._sans_font, config._subheading_size, style: "italic", weight: 500, black, body))
  v(config._lineskip)
}

#let make-index(config, group: "default", indent: 1em, separator: [, ], columns: 3) = {
  justify-page()
  set page(header: none, footer: page-number(config, offset: config._page_margin_sep))
  heading(depth: 1, numbering: none, supplement: none, config.i18n.index)
  show: std.columns.with(columns)
  use_word_list(group, it => {
    for (id, entries) in it {
      heading(
        level: 3,
        depth: 1,
        numbering: none,
        id,
      )
      for entry in entries {
        let (word, children, min_page, max_page) = entry
        let _entry = {
          let page_range = if min_page == max_page {
            min_page
          } else {
            [#min_page\-#max_page]
          }
          block[#word#separator#page_range]
          for child in children {
            let (modifier, loc) = child
            if modifier == none { continue }
            block[#h(indent)#modifier#separator#loc.join(",")]
          }
        }
        block(_entry)
      }
    }
  })
}

#let asterism(config) = align(center, block(spacing: 2em, text(config._color_palette.accent)[✻ #h(1em) ✻ #h(1em) ✻]))
