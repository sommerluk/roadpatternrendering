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
