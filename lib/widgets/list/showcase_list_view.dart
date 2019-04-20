// Copyright 2019 Joshua de Guzman (https://jmdg.io). All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_moviehub/blocs/movie_list_bloc.dart';
import 'package:flutter_moviehub/model/models.dart';
import 'package:flutter_moviehub/widgets/items/showcase_item_view.dart';
import 'package:flutter_moviehub/widgets/list/base_list_view.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class ShowcaseListView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ShowcaseListViewState();
  }
}

class ShowcaseListViewState extends BaseListView<ShowcaseListView, MovieList> {
  String currentMovieTitle = '';
  String currentMovieDescription = '';
  double currentMovieRating = 0.0;

  @override
  void initState() {
    super.initState();

    // Retrieve upcoming movies
    movieListBloc.getUpcomingMovies();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: movieListBloc.upcomingMoviesList,
      builder: (context, AsyncSnapshot<MovieList> snapshot) {
        if (snapshot.hasData) {
          return buildListView(snapshot, context);
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              snapshot.error.toString(),
            ),
          );
        }
        return Container(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  onShowcasedMovieChanged(Movie movie) {
    setState(() {
      currentMovieTitle = movie.title;
      currentMovieDescription = movie.overview;
      currentMovieRating = movie.voteAverage / 2;
    });
  }

  @override
  Widget buildListView(
    AsyncSnapshot<MovieList> snapshot,
    BuildContext context,
  ) {
    return Container(
      child: Column(
        children: <Widget>[
          // https://pub.dartlang.org/packages/carousel_slider
          CarouselSlider(
            height: 175,
            viewportFraction: 0.6,
            enableInfiniteScroll: true,
            autoPlay: true,
            autoPlayInterval: Duration(seconds: 3),
            autoPlayAnimationDuration: Duration(milliseconds: 800),
            // autoPlayCurve: Curve.fastOutSlowIn,
            pauseAutoPlayOnTouch: Duration(seconds: 10),
            enlargeCenterPage: true,
            onPageChanged: (index) {
              var movie = snapshot.data.results[index];
              onShowcasedMovieChanged(movie);
            },
            scrollDirection: Axis.horizontal,
            items: snapshot.data.results.map(
              (item) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width / 1.25,
                      child: buildShowcaseItemView(item),
                    );
                  },
                );
              },
            ).toList(),
          ),
          _buildMovieShowcaseDetails(),
        ],
      ),
    );
  }

  Widget _buildMovieShowcaseDetails() {
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            currentMovieTitle,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          // https://stackoverflow.com/questions/44579918/flutter-insert-overflow-ellipsis-in-text
          Text(
            currentMovieDescription,
            overflow: TextOverflow.ellipsis,
            maxLines: 3,
            style: TextStyle(
              color: Colors.white70,
            ),
          ),
          Row(
            children: <Widget>[
              FlatButton.icon(
                padding: EdgeInsets.all(0),
                icon: Icon(
                  Icons.timer,
                  color: Colors.white,
                  size: 16,
                ),
                color: Colors.transparent,
                label: Text(
                  'Watch Later',
                  style: TextStyle(color: Colors.white, fontSize: 12.0),
                ),
                onPressed: () {},
              ),
              FlatButton.icon(
                padding: EdgeInsets.all(0),
                icon: Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: 16,
                ),
                color: Colors.transparent,
                label: Text(
                  'Info',
                  style: TextStyle(color: Colors.white, fontSize: 12.0),
                ),
                onPressed: () {},
              ),
              SmoothStarRating(
                rating: currentMovieRating,
                allowHalfRating: true,
                size: 12,
                starCount: 5,
                color: Colors.white,
              ),
            ],
          )
        ],
      ),
    );
  }
}
