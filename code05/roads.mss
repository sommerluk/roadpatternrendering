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
