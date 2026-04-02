import FS from "node:fs"
import Path from "node:path"
import * as Fn from "@dashkite/joy/function"
import Pug from "pug"
import { coffee } from "@dashkite/masonry-coffee"
import { stylus } from "@dashkite/masonry-stylus"
import { markdown } from "@dashkite/masonry-markdown"
import { yaml } from "@dashkite/masonry-yaml"
import xxhash from "xxhash-wasm"

templates = {}

parsePath = ( path ) ->
  { dir, name, ext } = Path.parse path
  path: path
  directory: dir
  name: name
  extension: ext

Filters = 
  make: ({ root, source, input, build }) ->
    root = build.root ? root
    coffee: ( input ) -> coffee { root, source, input, build }
    markdown: ( input ) -> md { root, source, input }
    stylus: ( input, options ) -> 
      root = build.root ? root
      source = parsePath Path.relative root, options.filename
      stylus { root, source, input, build }
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
  # Pug.render input, {
  #   filename, basedir: root, build.context...,
  #   filters, include, data
  # }
  key = hash JSON.stringify [ filename, input ]
  template = templates[ key ] ?=
    Pug.compile input, {
      filename, basedir: root, filters, 
      build.context...
    }
  template {
    filename, basedir: root, filters, 
    build.context...
    include, data
  }


Presets = { html, js }

md = hash = null
templates = {}
pug = ( context ) ->
  md ?= await markdown()
  hash ?= ( await xxhash()).h32
  if ( preset = Presets[ context.build.preset ])?
    await preset context
  else
    throw new Error "masonry-pug: 
      unknown Pug preset #{ context.build.preset }"

export default pug
export { pug }
