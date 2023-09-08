import Pug from "pug"
import modularize from "@dashkite/masonry-export"
import { coffee } from "@dashkite/masonry-coffee"
import { stylus } from "@dashkite/masonry-stylus"
import { markdown } from "@dashkite/masonry-markdown"
import { yaml } from "@dashkite/masonry-yaml"

js = ({ root, source, input, build }) ->
  Pug.compileClient input,
    filename: source?.path
    basedir: root
    filters:
      coffee: ( input ) -> coffee { root, source, input }
      markdown: ( input ) -> markdown { root, source, input }
      stylus: ( input ) -> stylus { root, source, input }
      yaml: ( input ) -> yaml { root, source, input }

html = ({ root, source, input, data }) ->
  Pug.render input,
    filename: source?.path
    basedir: root
    # TODO make it possible to write to the data attribute
    data: data
    filters:
      coffee: ( input ) -> coffee { root, source, input }
      markdown: ( input ) -> markdown { root, source, input }
      stylus: ( input ) -> stylus { root, source, input }
      yaml: ( input ) -> yaml { root, source, input }

Presets = { html, js }

_pug = ( context ) ->
  if ( preset = Presets[ context.build.preset ])?
    await preset context
  else
    throw new Error "masonry: unknown Pug preset #{ context.build.preset }"

pug = [
  _pug
  modularize
]

export default pug
export { pug }
