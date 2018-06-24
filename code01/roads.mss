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
