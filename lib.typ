/// lib.typ
/// entrypoint for the library

// re-export the following modules

#let config-uwni(
  /// lzh: 文言
  /// zh: 標準漢語
  /// en: English
  /// dictionary: custom preset
  preset: "en",
  title: (lzh: [], zh: [], en: []),
  author: "[Author]",
  affiliation: "[Department]",
  date: datetime.today(),
  draft: false,
  two-sided: false,
  title-style: "[title-style]",
  chap-imgs: (),
) = {
  import "src/components.typ": heavyrule, midrule
  import "src/template.typ": template, appendix, subheading, _outline, make-index, mainbody
  import "src/titlepage.typ": titlepage
  import "src/environments.typ": _proposition, _highlighteq, _example, _definition, _proof

  let preset = if type(preset) == str {
    import "src/presets/config-" + str(preset) + ".typ" as default
    dictionary(default)
  } else if type(preset) == module {
    dictionary(preset)
  } else if type(preset) == dictionary {
    preset
  } else {
    panic("preset must be a string or a module or dictionary")
  }

  // export the following functions
  (
    template: template.with(
      preset,
      title,
      author,
      date,
      draft,
      two-sided,
      chap-imgs,
    ),
    titlepage: titlepage(
      preset,
      style: title-style,
      title,
      author,
      affiliation,
      date,
      draft,
    ),
    appendix: appendix.with(preset),
    mainbody: body => mainbody(preset, body, two-sided, chap-imgs),
    subheading: subheading.with(preset),
    outline: _outline.with(preset),
    proposition: _proposition.with(preset),
    highlighteq: _highlighteq.with(preset),
    example: _example.with(preset),
    definition: _definition.with(preset),
    proof: _proof.with(preset),
    components: (heavyrule: heavyrule(preset), midrule: midrule(preset)),
    make-index: make-index.with(preset),
  )
}

// reexport
#import "src/index.typ": index
#import "src/template.typ": preamble, asterism
#import "src/environments.typ": multi-row
#import "src/components.typ": justify-page
