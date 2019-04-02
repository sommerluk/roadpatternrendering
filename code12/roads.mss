Map {
  background-color: white;
}

#roads-fill {

  ::fill {

    [feature = 'highway_primary'] {
        line-color: #fcd6a4;
        line-width: 10;
        [int_surface = 'unpaved'] {
          line-pattern-type: repeat;
          line-pattern-file: url('symbols/unpaved/unpaved_primary-fill.svg');
          line-pattern-alignment: global;
          line-pattern-width: 10;
          line-pattern-cap: round;
          line-pattern-join: round;
        }
        [zoom >= 18] {
          line-width: 15;
          [int_surface = 'unpaved'] { line-pattern-width: 15; }
        }
        [zoom >= 19] {
          line-width: 20;
          [int_surface = 'unpaved'] { line-pattern-width: 20; }
        }
        line-cap: round;
        line-join: round;
    }

    [feature = 'highway_secondary'] {
        line-color: #f7fabf;
        line-width: 5;
        [int_surface = 'unpaved'] {
          line-pattern-type: repeat;
          line-pattern-file: url('symbols/unpaved/unpaved_secondary-fill.svg');
          line-pattern-alignment: global;
          line-pattern-width: 5;
          line-pattern-cap: round;
          line-pattern-join: round;
        }
        [zoom >= 18] {
          line-width: 10;
          [int_surface = 'unpaved'] { line-pattern-width: 10; }
        }
        [zoom >= 19] {
          line-width: 15;
          [int_surface = 'unpaved'] { line-pattern-width: 15; }
        }
        line-cap: round;
        line-join: round;
    }

  }

}
