import Pug from "pug"
import modularize from "@dashkite/masonry-modularize"
import { coffee } from "@dashkite/masonry-coffee"
import { stylus } from "@dashkite/masonry-stylus"
import { markdown } from "@dashkite/masonry-markdown"
import { yaml } from "@dashkite/masonry-yaml"

js = modularize ({ root, source, input, build }) ->
  build.target, Pug.compileClient input,
    filename: source?.path
    basedir: root
    filters:
      coffee: ( input ) -> coffee { root, source }
      markdown: ( input ) -> markdown { root, source }
      stylus: ( input ) -> stylus { root, source }
      yaml: ( input ) -> yaml { root, source }

html = ({ root, source, input, data }) ->
  Pug.render input,
    filename: source?.path
    basedir: root
    # TODO make it possible to write to the data attribute
    data: data
    filters:
      coffee: ( input ) -> coffee { root, source }
      markdown: ( input ) -> markdown { root, source }
      stylus: ( input ) -> stylus { root, source }
      yaml: ( input ) -> yaml { root, source }

Presets = { html, js }

pug = ( context ) ->
  if ( preset = Presets[ context.build.preset ])?
    await preset context
  else
    throw new Error "masonry: unknown Pug preset #{ context.build.preset }"

export { pug }
