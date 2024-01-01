import Pug from "pug"
# import modularize from "@dashkite/masonry-export"
import { coffee } from "@dashkite/masonry-coffee"
import { stylus } from "@dashkite/masonry-stylus"
import { markdown } from "@dashkite/masonry-markdown"
import { yaml } from "@dashkite/masonry-yaml"

js = ({ root, source, input, build }) ->
  f = Pug.compileClient input,
    filename: source?.path
    basedir: root
    filters:
      coffee: ( input ) -> coffee { root, source, input, build }
      markdown: ( input ) -> markdown { root, source, input }
      stylus: ( input ) -> stylus { root, source, input, build }
      yaml: ( input ) -> yaml { root, source, input, build }
  # TODO figure out how to generalize in masonry-export
  switch build.target
    when "browser"
      "#{ f }\nexport default template"
    when "node"
      "#{ f }\nmodule.exports = template;"

html = ({ root, source, input, data, build }) ->
  Pug.render input, {
    filename: source?.path
    basedir: root
    # TODO make it possible to write to the data attribute
    data: data
    filters:
      coffee: ( input ) -> coffee { root, source, input, build }
      markdown: ( input ) -> markdown { root, source, input }
      stylus: ( input ) -> stylus { root, source, input, build }
      yaml: ( input ) -> yaml { root, source, input, build }
    build.context...
  }

Presets = { html, js }

_pug = ( context ) ->
  if ( preset = Presets[ context.build.preset ])?
    await preset context
  else
    throw new Error "masonry: unknown Pug preset #{ context.build.preset }"

# pug = [
#   _pug
#   modularize
# ]

pug = _pug
export default pug
export { pug }
