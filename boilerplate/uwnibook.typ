///
/// this file is used to import and config packages
///

#import "@local/monokro:0.1.0": *
#import "header_imgs/imgs.typ": imgs

#let (
  template,
  titlepage,
  outline,
  mainbody,
  appendix,
  proposition,
  highlighteq,
  example,
  definition,
  proof,
  components,
  make-index,
  subheading,
) = config-uwni(
  /// ["en"|"zh"|"lzh"]
  preset: "zh",
  title: (
    en: [
      Uwni Book
    ],
    zh: [
      Uwni 書籍模板
    ],
  ),
  // author information
  author: (en: "Uwni", zh: "著者"),
  // author affiliation
  affiliation: [部門，機構],
  // report date
  date: datetime.today(),
  // set to true to enable draft watermark, so that you can prevent from submitting a draft version
  draft: false,
  // set to true to enable two-sided layout
  two-sided: true,
  // "modern"|"classic"
  title-style: "book",
  chap-imgs: imgs,
)
