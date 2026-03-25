import FS from "node:fs"
import Path from "node:path"
import * as Fn from "@dashkite/joy/function"
import Pug from "pug"
# import modularize from "@dashkite/masonry-export"
import { coffee } from "@dashkite/masonry-coffee"
import { stylus } from "@dashkite/masonry-stylus"
import { markdown } from "@dashkite/masonry-markdown"
# import { textile } from "@dashkite/masonry-textile"
import { yaml } from "@dashkite/masonry-yaml"

Filters = 
  make: ({ root, source, input, build }) ->
    coffee: ( input ) -> coffee { root, source, input, build }
    markdown: ( input ) -> markdown { root, source, input }
    # textile: ( input ) -> textile { root, source, input }
    stylus: ( input ) -> stylus { root, source, input, build }
    yaml: ( input ) -> yaml { root, source, input, build }

js = ({ root, source, input, build }) ->
  root = root ? build.root
  filename = Path.join root, source?.path
  filters = Filters.make { root, source, input, build }
  f = Pug.compileClient input, { filename, basedir: root, filters }
  switch build.target
    when "browser"
      "#{ f }\nexport default template"
    when "node"
      "#{ f }\nmodule.exports = template;"

html = ({ root, source, input, data, build }) ->
  root = root ? build.root
  filename = Path.join root, source?.path
  filters = Filters.make { root, source, input, build }
  include = ( filter, path ) ->
    [ path, filter ] = if path? then [ path, filter ] else [ filter ]
    path = if path.startsWith "/"
      Path.join root, path[1..]
    else
      Path.join root, source.directory, path
    content = FS.readFileSync path, "utf8"
    if ( k = filters[ filter ])? then k content else content
  Pug.render input, {
    filename, basedir: root, data, filters, include
    build.context...
  }

Presets = { html, js }

_pug = Fn.tee ( context ) ->
  if ( preset = Presets[ context.build.preset ])?
    context.output = await preset context
  else
    throw new Error "masonry-pug: 
      unknown Pug preset #{ context.build.preset }"

# pug = [
#   _pug
#   modularize
# ]

pug = _pug
export default pug
export { pug }
