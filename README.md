# Abstract

This is a tutorial about how to render on a map road line surfaces with an irregular-looking pattern using a software stack with Mapnik and CartoCSS.

Why would you want to do this? A possible use case for this is rendering the road surface. You could render paved roads with a full colour, while rendering unpaved roads with the irregular-looking pattern:

![](images/example10.png?raw=true)

This document presents various different technical approaches and discusses the advantages and disadvantages of each of them.

# The example style

We start with an example style. We use the same setup as the [“openstreetmap-carto” style](https://github.com/gravitystorm/openstreetmap-carto). Especially we use the same database layout, and therefor we copy `openstreetmap-carto.lua` and `openstreetmap.carto.style` from there. Now we start with a simple `project.mml` that queries some roads from the OSM database:

```yaml
center:
  - 0
  - 0
  - 4

# Various parts to be included later on
_parts:
  # Extents are used for tilemill, and don't actually make it to the generated XML
  osm2pgsql: &osm2pgsql
    type: "postgis"
    dbname: "gis"
    key_field: ""
    geometry_field: "way"
    extent: "-20037508,-20037508,20037508,20037508"

Stylesheet:
  - roads.mss

Layer:
  - id: roads-fill
    geometry: linestring
    Datasource:
      <<: *osm2pgsql
      table: |-
        (SELECT
            way,
            feature,
            layernotnull,
            z_order
          FROM (
            SELECT
                way,
                'highway_' || highway AS feature,
                COALESCE(layer,0) AS layernotnull,
                z_order
              FROM planet_osm_line
            ) AS features
          ORDER BY
            layernotnull,
            z_order
        ) AS roads_fill
```

- The query `'highway_' || highway AS feature` creates a column `feature`. Roads with `highway=primary`  for example get `feature=highway_primary`.

- In OSM, the vertical order of bridges and tunnels can be described with the `layer` key: If two bridges are crossing, the higher one gets the higher `layer` value. We calculate `layernotnull` with `COALESCE(layer,0) AS layernotnull`: If an element has a valid `layer` value, it is used. Otherwise, `0` is used as default value.

- `z_order` is an integer value that is calculated during database import (see `openstreetmap-carto.lua` for details) for all roads: More important road types get higher the `z_order` values. `highway=primary` has `z_order=360`. `highway=secondary` has `z_order=350`.

- We order first by layernotnull, and than by z_order. So for a normal crossroad between a primary and a secondary road (both with `layer=0`), the primary road is rendered above the secondary road because it’s the primary road is the more important one. But a secondary road on a bridge with `layer=2` is rendered above a primary road with `layer=0` on the ground.

This is the corresponding `roads.mss`:

```cartocss
Map {
  background-color: white;
}

#roads-fill {

  ::fill {

    [feature = 'highway_primary'] {
        line-color: #fcd6a4;
        line-width: 10;
        [zoom >= 18] { line-width: 15; }
        [zoom >= 19] { line-width: 20; }
    }

    [feature = 'highway_secondary'] {
        line-color: #f7fabf;
        line-width: 5;
        [zoom >= 18] { line-width: 10; }
        [zoom >= 19] { line-width: 15; }
    }

  }

}
```

On higher zoom levels, the roads are drawn thicker than on lower zoom levels. And within each zoom level, the primary roads are drawn thicker than the secondary roads.

We use example data. From top left to bottom right we have:
- primary road, paved
- secondary road, paved
- primary road, unpaved, layer 1
- secondary road, unpaved, layer 1
- primary road, unpaved, layer 2
- secondary road, unpaved, layer 2

At some of the corners, the road line is split, at other it is continous.

The code is available at `code01` and it renders like this:

![](images/example01.png?raw=true)

In this rendering, whereever a road is split into two OSM ways, the rendering is different and ugly compared to OSM nodes in the middle of a single OSM way. Round forms give us a better rendering:

```cartocss
Map {
  background-color: white;
}

#roads-fill {

  ::fill {

    [feature = 'highway_primary'] {
        line-color: #fcd6a4;
        line-width: 10;
        [zoom >= 18] { line-width: 15; }
        [zoom >= 19] { line-width: 20; }
        line-cap: round;
        line-join: round;
    }

    [feature = 'highway_secondary'] {
        line-color: #f7fabf;
        line-width: 5;
        [zoom >= 18] { line-width: 10; }
        [zoom >= 19] { line-width: 15; }
        line-cap: round;
        line-join: round;
    }

  }

}
```

The code is available at `code02` and it renders like this:

![](images/example02.png?raw=true)

Now we try to render unpaved roads differently from paved roads: We want to render them with an irregular-looking pattern, reminding the user about the uneven surface of these roads. Therefor, we have to query the surface key from the OSM database. We will also order the data by surface, so that a paved secondary road is rendered above an unpaved secondary road, but still below an unpaved primary road (though this will occur rather seldom in the OSM database):

```yaml
center:
  - 0
  - 0
  - 4

# Various parts to be included later on
_parts:
  # Extents are used for tilemill, and don't actually make it to the generated XML
  osm2pgsql: &osm2pgsql
    type: "postgis"
    dbname: "gis"
    key_field: ""
    geometry_field: "way"
    extent: "-20037508,-20037508,20037508,20037508"

Stylesheet:
  - roads.mss

Layer:
  - id: roads-fill
    geometry: linestring
    Datasource:
      <<: *osm2pgsql
      table: |-
        (SELECT
            way,
            feature,
            int_surface,
            layernotnull,
            z_order
          FROM (
            SELECT
                way,
                'highway_' || highway AS feature,
                surface AS int_surface,
                COALESCE(layer,0) AS layernotnull,
                z_order
              FROM planet_osm_line
            ) AS features
          ORDER BY
            layernotnull,
            z_order,
            CASE WHEN int_surface IN ('unpaved') THEN 0 ELSE 2 END
        ) AS roads_fill
```

The code is available at `code03`.

# Pattern rendering with line-pattern

Now we have to write MSS code that actually renders a pattern. The natural choise would be Mapnik’s [line-pattern feature](http://mapnik.org/mapnik-reference/#3.0.20/line-pattern). Mapnik renders this pattern following the geometry of the OSM way, blending it at angles within the OSM way. We create a SVG pattern file with the correct height for each existing combination of road type and width:

```cartocss
Map {
  background-color: white;
}

#roads-fill {

  ::fill {

    [feature = 'highway_primary'] {
        line-color: #fcd6a4;
        line-width: 10;
        [int_surface = 'unpaved'] { line-pattern-file: url("symbols/unpaved/unpaved_primary-fill_10.svg"); }
        [zoom >= 18] {
          line-width: 15;
          [int_surface = 'unpaved'] { line-pattern-file: url("symbols/unpaved/unpaved_primary-fill_15.svg"); }
        }
        [zoom >= 19] {
          line-width: 20;
          [int_surface = 'unpaved'] { line-pattern-file: url("symbols/unpaved/unpaved_primary-fill_20.svg"); }
        }
        line-cap: round;
        line-join: round;
    }

    [feature = 'highway_secondary'] {
        line-color: #f7fabf;
        line-width: 5;
        [int_surface = 'unpaved'] { line-pattern-file: url("symbols/unpaved/unpaved_secondary-fill_5.svg"); }
        [zoom >= 18] {
          line-width: 10;
          [int_surface = 'unpaved'] { line-pattern-file: url("symbols/unpaved/unpaved_secondary-fill_10.svg"); }
        }
        [zoom >= 19] {
          line-width: 15;
          [int_surface = 'unpaved'] { line-pattern-file: url("symbols/unpaved/unpaved_secondary-fill_15.svg"); }
        }
        line-cap: round;
        line-join: round;
    }

  }

}
```

Obviously we need an own pattern file for each combination between colour and width. Mapnik renders the pattern as it is. Options like `line-pattern-cap` and `line-pattern-join` are not available.

The code is available at `code04` and it renders like this:

![](images/example04.png?raw=true)

Advantages:
- MMS code is easy to understand.
- SQL code is trivial.

Disadvantages:
- MMS code is verbose.
- We need many pattern files (one for each combination of road colour and width – could be generated automatically by a script?).
- Changes to the road width requiere adapting the pattern files.
- Rendering artefacts on joints of OSM ways and crossing OSM ways and within OSM ways if the angle is extreme.
- Does not look good for very thin road lines

# Pattern rendering with dash-array

An alternative to line-pattern exists: We can print various irregular dash-arrays to get a random-looking pattern.

```cartocss
Map {
  background-color: white;
}

#roads-fill {

  ::fill {

    [feature = 'highway_primary'] {
        line-color: #fcd6a4;
        line-width: 10;
        [int_surface = 'unpaved'] {
          line-color: #ffe1af;
          b/line-dasharray: 0.9,3,1,2,1,1,1,2.1,;
          b/line-offset: 3;
          b/line-width: 0.4;
          b/line-color: #573d12;
          c/line-dasharray: 1,3,1,2.2,0.9,1,1,3,1,2.2;
          c/line-offset: 1;
          c/line-width: 0.4;
          c/line-color: #573d12;
          d/line-dasharray: 1,3,1.1,2.4,1,1.3,;
          d/line-offset: -1;
          d/line-width: 0.4;
          d/line-color: #573d12;
          e/line-dasharray: 1,3.1,1,2.4,;
          e/line-offset: -3;
          e/line-width: 0.4;
          e/line-color: #573d12;
        }
        [zoom >= 18] {
          line-width: 15;
          [int_surface = 'unpaved'] {
            line-color: #ffe1af;
            b/line-dasharray: 0.9,3,1,2,1,1,1,2.1,;
            b/line-offset: 6;
            b/line-width: 0.4;
            b/line-color: #573d12;
            c/line-dasharray: 1,3,1,2.2,0.9,1,1,3,1,2.2;
            c/line-offset: 4;
            c/line-width: 0.4;
            c/line-color: #573d12;
            d/line-dasharray: 1,3,1.1,2.4,1,1.3,;
            d/line-offset: 2;
            d/line-width: 0.4;
            d/line-color: #573d12;
            e/line-dasharray: 1,3.1,1,2.1.4,;
            e/line-offset: 0;
            e/line-width: 0.4;
            e/line-color: #573d12;
            f/line-dasharray: 0.9,3,1,2,1,1,1,2.5,;
            f/line-offset: -2;
            f/line-width: 0.4;
            f/line-color: #573d12;
            g/line-dasharray: 1,3,1,2.2,0.9,1,1,3,1,2.6;
            g/line-offset: -4;
            g/line-width: 0.4;
            g/line-color: #573d12;
            h/line-dasharray: 1,3,1.1,2.4,1,1.7,;
            h/line-offset: -6;
            h/line-width: 0.4;
            h/line-color: #573d12;
          }
        }
        [zoom >= 19] {
          line-width: 20;
          [int_surface = 'unpaved'] {
            line-color: #ffe1af;
            b/line-dasharray: 0.9,3,1,2,1,1,1,2.1,;
            b/line-offset: 8;
            b/line-width: 0.4;
            b/line-color: #573d12;
            c/line-dasharray: 1,3,1,2.2,0.9,1,1,3,1,2.2;
            c/line-offset: 6;
            c/line-width: 0.4;
            c/line-color: #573d12;
            d/line-dasharray: 1,3,1.1,2.4,1,1.3,;
            d/line-offset: 4;
            d/line-width: 0.4;
            d/line-color: #573d12;
            e/line-dasharray: 1,3.1,1,2.1.4,;
            e/line-offset: 2;
            e/line-width: 0.4;
            e/line-color: #573d12;
            f/line-dasharray: 0.9,3,1,2,1,1,1,2.5,;
            f/line-offset: 0;
            f/line-width: 0.4;
            f/line-color: #573d12;
            g/line-dasharray: 1,3,1,2.2,0.9,1,1,3,1,2.6;
            g/line-offset: -2;
            g/line-width: 0.4;
            g/line-color: #573d12;
            h/line-dasharray: 1,3,1.1,2.4,1,1.7,;
            h/line-offset: -4;
            h/line-width: 0.4;
            h/line-color: #573d12;
            i/line-dasharray: 1,3.1,1,2.1.8,;
            i/line-offset: -6;
            i/line-width: 0.4;
            i/line-color: #573d12;
            j/line-dasharray: 0.9,3,1,2,1,1,1,2.9,;
            j/line-offset: -8;
            j/line-width: 0.4;
            j/line-color: #573d12;
          }
        }
        line-cap: round;
        line-join: round;
    }

    [feature = 'highway_secondary'] {
        line-color: #f7fabf;
        line-width: 5;
          [int_surface = 'unpaved'] {
            line-color: #ffffc7;
            b/line-dasharray: 0.9,3,1,2,1,1,1,2.1,;
            b/line-offset: 2;
            b/line-width: 0.4;
            b/line-color: #565a28;
            c/line-dasharray: 1,3,1,2.2,0.9,1,1,3,1,2.2;
            c/line-offset: 0;
            c/line-width: 0.4;
            c/line-color: #565a28;
            d/line-dasharray: 1,3,1.1,2.4,1,1.3,;
            d/line-offset: -2;
            d/line-width: 0.4;
            d/line-color: #565a28;
          }
        [zoom >= 18] {
          line-width: 10;
          [int_surface = 'unpaved'] {
            line-color: #ffffc7;
            b/line-dasharray: 0.9,3,1,2,1,1,1,2.1,;
            b/line-offset: 3;
            b/line-width: 0.4;
            b/line-color: #565a28;
            c/line-dasharray: 1,3,1,2.2,0.9,1,1,3,1,2.2;
            c/line-offset: 1;
            c/line-width: 0.4;
            c/line-color: #565a28;
            d/line-dasharray: 1,3,1.1,2.4,1,1.3,;
            d/line-offset: -1;
            d/line-width: 0.4;
            d/line-color: #565a28;
            e/line-dasharray: 1,3.1,1,2.4,;
            e/line-offset: -3;
            e/line-width: 0.4;
            e/line-color: #565a28;
          }
        }
        [zoom >= 19] {
          line-width: 15;
          [int_surface = 'unpaved'] {
            line-color: #ffffc7;
            b/line-dasharray: 0.9,3,1,2,1,1,1,2.1,;
            b/line-offset: 6;
            b/line-width: 0.4;
            b/line-color: #565a28;
            c/line-dasharray: 1,3,1,2.2,0.9,1,1,3,1,2.2;
            c/line-offset: 4;
            c/line-width: 0.4;
            c/line-color: #565a28;
            d/line-dasharray: 1,3,1.1,2.4,1,1.3,;
            d/line-offset: 2;
            d/line-width: 0.4;
            d/line-color: #565a28;
            e/line-dasharray: 1,3.1,1,2.1.4,;
            e/line-offset: 0;
            e/line-width: 0.4;
            e/line-color: #565a28;
            f/line-dasharray: 0.9,3,1,2,1,1,1,2.5,;
            f/line-offset: -2;
            f/line-width: 0.4;
            f/line-color: #565a28;
            g/line-dasharray: 1,3,1,2.2,0.9,1,1,3,1,2.6;
            g/line-offset: -4;
            g/line-width: 0.4;
            g/line-color: #565a28;
            h/line-dasharray: 1,3,1.1,2.4,1,1.7,;
            h/line-offset: -6;
            h/line-width: 0.4;
            h/line-color: #565a28;
          }
        }
        line-cap: round;
        line-join: round;
    }

  }

}
```

This code is based on Mapnik’s ability to render various lines for a single geometry – here starting with `b/`, `c/` and so on. For these lines, we use a dasharray that looks irregualar. Furhtermore, each of these dasharrays has a different length to make sure that we do not get a regular-looking pattern on long straight line geometries. The larger our normal road line is, the more dasharray lines we need.

The code is available at `code05` and it renders like this:

![](images/example05.png?raw=true)

Advantages:
- SQL code is trivial.
- Looks good also for very thin road lines

Disadvantages:
- MMS code is redundant and extremely verbose.
- Changes to the road width requiere adapting the code for the dash-arrays.
- Rendering artefacts on joints of OSM ways and crossing OSM ways and within OSM ways if the angle is extreme.

# Pattern rendering with dst-out

To get a rendering without any artefacts, we would need something like a `polygon-pattern`. This pattern would not be blended following the line geometry, but it would be aligned globally like normal `polygon-pattern`, just only visible where the line geometry of the road is, considering also `line-cap` and `line-join` for the road. This would even guarantee smooth rendering without any artefacts for example for a primary unpaved and a secondary unpaved road crossing (if we use the same pattern for these road types and just change the colour). It would also play very well together with `area:highway` rendering of polygon geometries: both could use the same pattern file.

Unfourtunally, Mapnik has no build-in support for direct polygon-pattern rendering for line geometries. But we can archieve the same rendering nevertheless. It’ just a little bit tricky.

By default, Mapnik draws newer elements _above_ everything that is yet rendered. But this behaviour can be customized with the `comp-op` parameter.

## Apply dst-out to unpaved roads

```cartocss
Map {
  background-color: white;
}

#roads-fill {

  ::fill {

    [feature = 'highway_primary'] {
        line-color: #fcd6a4;
        line-width: 10;
        [int_surface = 'unpaved'] { line-comp-op: dst-out; }
        [zoom >= 18] {
          line-width: 15;
        }
        [zoom >= 19] {
          line-width: 20;
        }
        line-cap: round;
        line-join: round;
    }

    [feature = 'highway_secondary'] {
        line-color: #f7fabf;
        line-width: 5;
        [int_surface = 'unpaved'] { line-comp-op: dst-out; }
        [zoom >= 18] {
          line-width: 10;
        }
        [zoom >= 19] {
          line-width: 15;
        }
        line-cap: round;
        line-join: round;
    }

  }

}
```

Applying `line-comp-op: dst-out;` tells Mapnik to not actually draw the line, but instead cut a hole in the yet existing rendering canvas.

The code is available at `code06` and it renders like this:

![](images/example06.png?raw=true)

## Render the polygon-pattern

Now we have to render the polygon pattern _behind_ the existing rendering canvas, so that it will be visible only where we had cut a hole in the rendering canvas previously.

```cartocss
Map {
  background-color: white;
}

#roads-fill {

  ::fill {

    [feature = 'highway_primary'] {
        line-color: #fcd6a4;
        line-width: 10;
        [int_surface = 'unpaved'] { line-comp-op: dst-out; }
        [zoom >= 18] {
          line-width: 15;
        }
        [zoom >= 19] {
          line-width: 20;
        }
        line-cap: round;
        line-join: round;
    }

    [feature = 'highway_secondary'] {
        line-color: #f7fabf;
        line-width: 5;
        [int_surface = 'unpaved'] { line-comp-op: dst-out; }
        [zoom >= 18] {
          line-width: 10;
        }
        [zoom >= 19] {
          line-width: 15;
        }
        line-cap: round;
        line-join: round;
    }

  }

  ::primary-fill-pattern {
    [feature = 'globalboundingbox'] {
      polygon-pattern-comp-op: dst-over;
      polygon-pattern-file: url('symbols/unpaved/unpaved_primary-fill.svg');
      polygon-pattern-alignment: global;
    }
  }

}
```

The line `polygon-pattern-comp-op: dst-over;` will make render the polygon-pattern _behind_ the canvas instead of _above_. Our MSS code contains two so-called “attachments”: `fill` and `primary-fill-pattern`. Attachments are rendered by order: Attachments that occur earlier in the code are rendered earlier; attachments that accur later in the code are rendered later. The attachment order has priority over the order done by `ORDER BY` in the SQL query! Therefor, out pattern will be rendered _later_ than the road lines.

We want that the polygon pattern is rendered everywhere, on the whole planet – always behind the canvas. Unfourtunally, Mapnik cannot simply render a polygon pattern on the whole planet; it needs an actual geometry. So we need to create a sort of “fake” polygon that covers the whole planet. This can be done in the SQL query:

```yaml
center:
  - 0
  - 0
  - 4

# Various parts to be included later on
_parts:
  # Extents are used for tilemill, and don't actually make it to the generated XML
  osm2pgsql: &osm2pgsql
    type: "postgis"
    dbname: "gis"
    key_field: ""
    geometry_field: "way"
    extent: "-20037508,-20037508,20037508,20037508"

Stylesheet:
  - roads.mss

Layer:
  - id: roads-fill
    geometry: linestring
    Datasource:
      <<: *osm2pgsql
      table: |-
        (SELECT
            way,
            feature,
            int_surface,
            layernotnull,
            z_order
          FROM (
            SELECT
                way,
                'highway_' || highway AS feature,
                surface AS int_surface,
                COALESCE(layer,0) AS layernotnull,
                z_order
              FROM planet_osm_line
            UNION ALL
            (SELECT
                ST_MakeEnvelope(-20037508.342789244, -20037508.342789244, 20037508.342789244, 20037508.342789244, 900913) AS way,
                'globalboundingbox' AS feature,
                NULL AS layernotnull,
                NULL AS int_surface,
                NULL AS z_order
            )
            ) AS features
          ORDER BY
            layernotnull,
            z_order,
            CASE WHEN int_surface IN ('unpaved') THEN 0 ELSE 2 END
        ) AS roads_fill
```

This create _one_ polygon that covers the whole canvas that we render in our style.

The code is available at `code07` and it renders like this:

![](images/example07.png?raw=true)

But currently we render only the pattern for the primary roads, so unpaved secondary roads get the same colour as unpaved primary roads. To change this, we have to reorganize our MSS code.

```cartocss
Map {
  background-color: white;
}

#roads-fill {

  ::secondary-fill {

    [feature = 'highway_secondary'] {
        line-color: #f7fabf;
        line-width: 5;
        [int_surface = 'unpaved'] { line-comp-op: dst-out; }
        [zoom >= 18] {
          line-width: 10;
        }
        [zoom >= 19] {
          line-width: 15;
        }
        line-cap: round;
        line-join: round;
    }

  }

  ::secondary-fill-pattern {
    [feature = 'globalboundingbox'] {
      polygon-pattern-comp-op: dst-over;
      polygon-pattern-file: url('symbols/unpaved/unpaved_secondary-fill.svg');
      polygon-pattern-alignment: global;
    }
  }

  ::primary-fill {

    [feature = 'highway_primary'] {
        line-color: #fcd6a4;
        line-width: 10;
        [int_surface = 'unpaved'] { line-comp-op: dst-out; }
        [zoom >= 18] {
          line-width: 15;
        }
        [zoom >= 19] {
          line-width: 20;
        }
        line-cap: round;
        line-join: round;
    }

  }

  ::primary-fill-pattern {
    [feature = 'globalboundingbox'] {
      polygon-pattern-comp-op: dst-over;
      polygon-pattern-file: url('symbols/unpaved/unpaved_primary-fill.svg');
      polygon-pattern-alignment: global;
    }
  }

}
```

We want to render more important roads above less important roads. Therefor we have to split our MMS code into more attachments, and order them by road type, starting with the less important one. After each road type, we insert the code for the corresponding pattern.

The code is available at `code08` and it renders like this:

![](images/example08.png?raw=true)

Remark: _You do not need necessarily an own attachment for each z_order value. Imagine you have various road types like residential and service, that you render all in the same colour. Only one attachment for the code for of all these roads with the same colour (for example `unimportant-roads-fill`) and another attachment for the corresponding pattern (for example `unimportant-roads-fill-pattern`) is enough. And within the road attachment, the order from the SQL query applies._

## Support for `layer`

But this code does not consider the `layer` key anymore. That’s because of the rendering order. The general rendering order in Mapnik is like this:

1. The layers in the yaml file
2. group-by paramater (if any) of a layer in the yaml file
3. the attachments in the MSS code (for MSS rules that are not within an attachment, a default attachment is created)
4. the data order in the SQL query

So the attachment order has priority over the data order. If we still want to have support for `layer`, than we need another solution. A comfortable way to archieve the correct layer rendering again is using the `group-by` parameter to group roads by OSM layer:

```yaml
center:
  - 0
  - 0
  - 4

# Various parts to be included later on
_parts:
  # Extents are used for tilemill, and don't actually make it to the generated XML
  osm2pgsql: &osm2pgsql
    type: "postgis"
    dbname: "gis"
    key_field: ""
    geometry_field: "way"
    extent: "-20037508,-20037508,20037508,20037508"

Stylesheet:
  - roads.mss

Layer:
  - id: roads-fill
    geometry: linestring
    Datasource:
      <<: *osm2pgsql
      table: |-
        (SELECT
            way,
            feature,
            int_surface,
            layernotnull,
            z_order
          FROM (
            SELECT
                way,
                'highway_' || highway AS feature,
                surface AS int_surface,
                COALESCE(layer,0) AS layernotnull,
                z_order
              FROM planet_osm_line
            UNION ALL
            (SELECT
                ST_MakeEnvelope(-20037508.342789244, -20037508.342789244, 20037508.342789244, 20037508.342789244, 900913) AS way,
                'globalboundingbox' AS feature,
                NULL AS int_surface,
                0 AS layernotnull,
                NULL AS z_order
            )
            ) AS features
          ORDER BY
            layernotnull,
            z_order,
            CASE WHEN int_surface IN ('unpaved') THEN 0 ELSE 2 END
        ) AS roads_fill
    properties:
      group-by: layernotnull
```

Note that although we use `group-by: layernotnull` now, we still keep `layernotnull` also in the `ORDER BY` SQL statement. This is a requierement to make sure that `group-by` works as expected.

The code is available at `code09` and it renders like this:

![](images/example09.png?raw=true)

But this SQL query generates the fake polygon for the pattern rendering only once, for the OSM layer 0. It is missing for all other layers. So we need it for _each_ OSM layer that we render (at least if there are unpaved roads at this OSM layer):

```yaml
center:
  - 0
  - 0
  - 4

# Various parts to be included later on
_parts:
  # Extents are used for tilemill, and don't actually make it to the generated XML
  osm2pgsql: &osm2pgsql
    type: "postgis"
    dbname: "gis"
    key_field: ""
    geometry_field: "way"
    extent: "-20037508,-20037508,20037508,20037508"

Stylesheet:
  - roads.mss

Layer:
  - id: roads-fill
    geometry: linestring
    Datasource:
      <<: *osm2pgsql
      table: |-
        (SELECT
            way,
            feature,
            int_surface,
            layernotnull,
            z_order
          FROM (
            SELECT
                way,
                'highway_' || highway AS feature,
                surface AS int_surface,
                COALESCE(layer,0) AS layernotnull,
                z_order
              FROM planet_osm_line
            UNION ALL
            (SELECT
                ST_MakeEnvelope(-20037508.342789244, -20037508.342789244, 20037508.342789244, 20037508.342789244, 900913) AS way,
                'globalboundingbox' AS feature,
                NULL AS int_surface,
                layernotnull,
                NULL AS z_order
              FROM
                (SELECT DISTINCT
                    layernotnull
                  FROM
                    (SELECT
                        COALESCE(layer,0) AS layernotnull
                      FROM planet_osm_line
                      WHERE highway IS NOT NULL AND surface IN ('unpaved')
                    ) AS roads
                ) AS layers_list
            )
            ) AS features
          ORDER BY
            layernotnull,
            z_order,
            CASE WHEN int_surface IN ('unpaved') THEN 0 ELSE 2 END
        ) AS roads_fill
    properties:
      group-by: layernotnull
```

This query creates exactly _one_ fake polygon for _each_ OSM layer that occurs on OSM ways that have a `highway` tag and are also unpaved. We could also make the `WHERE` clause more restrictive, selecting at the `highway` tag only _primary_ and _secondary_ roads, which are the only ones we are currently rendering in this example style.

The code is available at `code10` and it renders like this:

![](images/example10.png?raw=true)

Advantages:
- Rendering artefacts on joints of OSM ways and crossing OSM ways and within OSM ways if the angle is extreme. Plays well also together with road areas (area:highway=*)
- Changes to the road width do not requiere any further changes.
- One pattern file per colour is enough

Disadvantages:
- The SQL query for the fake polygon is not really nice.
- Does not look good for very thin road lines
- The rendering with `dst-out` is not intuitive to understand. There is a complex interdependency between
  - the attachment order in the MSS file
  - the `ORDER` statements in the SQL querys
  - the SQL query for the fake polygon
  - and especially the `z_order` value (originally calculated in the Lua transform)
