import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:movielab/modules/api/api_requester.dart';
import 'package:movielab/modules/tools/image_quality_increaser.dart';

// Movie or TV show preview model class
class ShowPreview {
  final String id;
  final String rank;
  final String title;
  final String type;
  final String crew;
  final String image;
  final String year;
  final String? released;
  final String imDbRating;
  final String? imDbVotes;
  final String? seasonNumber;
  final String? episodeNumber;
  final String? plot;
  final String weekend;
  final String gross;
  final String weeks;
  final String worldwideLifetimeGross;
  final String domesticLifetimeGross;
  final String domestic;
  final String foreignLifetimeGross;
  final String foreign;
  final String? genres;
  final String? countries;
  final String? languages;
  final String? companies;
  final String? contentRating;
  final DateTime? watchDate;
  final TimeOfDay? watchTime;
  final List<ShowPreview>? similars;

  const ShowPreview({
    required this.id,
    required this.rank,
    required this.title,
    required this.type,
    required this.crew,
    required this.image,
    required this.year,
    this.released,
    required this.imDbRating,
    this.imDbVotes,
    this.seasonNumber,
    this.episodeNumber,
    this.plot,
    required this.weekend,
    required this.gross,
    required this.weeks,
    required this.worldwideLifetimeGross,
    required this.domesticLifetimeGross,
    required this.domestic,
    required this.foreignLifetimeGross,
    required this.foreign,
    this.genres,
    this.countries,
    this.languages,
    this.companies,
    this.contentRating,
    this.watchDate,
    this.watchTime,
    this.similars,
  });

  factory ShowPreview.fromJson(Map<String, dynamic> json) {
    return ShowPreview(
      id: json['id'].toString(),
      rank: "",
      title: json['title'] ?? json['name'] ?? "",
      type: json['media_type'] ?? "",
      crew: "",
      image: ImageUtils.addPrefix(json['poster_path']), // 添加前缀
      year: json['release_date']?.split("-")[0] ?? "",
      released: json['release_date'] ?? "",
      imDbRating: json['vote_average'].toString(),
      imDbVotes: json['vote_count'].toString(),
      seasonNumber: "",
      episodeNumber: "",
      plot: json['overview'] ?? "",
      weekend: "",
      gross: "",
      weeks: "",
      worldwideLifetimeGross: "",
      domesticLifetimeGross: "",
      domestic: "",
      foreignLifetimeGross: "",
      foreign: "",
      genres: json['genre_ids']?.join(", ") ?? "",
      countries: "",
      languages: json['original_language'] ?? "",
      companies: "",
      contentRating: "",
      watchDate: null,
      watchTime: null,
      similars: null,
    );
  }

  static Map<String, dynamic> toMap(ShowPreview show) => {
        'id': show.id,
        'rank': show.rank,
        'title': show.title,
        'type': show.type,
        'crew': show.crew,
        'image': show.image,
        'year': show.year,
        'imDbRating': show.imDbRating,
        'imDbVotes': show.imDbVotes,
        'released': show.released,
        'seasonNumber': show.seasonNumber,
        'episodeNumber': show.episodeNumber,
        'plot': show.plot,
        'genres': show.genres,
        'countries': show.countries,
        'languages': show.languages,
        'companies': show.companies,
        'contentRating': show.contentRating,
        'watchDate': show.watchDate?.toString(),
        'watchTime': show.watchTime?.toString(),
        'similars': [
          for (var similar in show.similars!) ShowPreview.toMap(similar)
        ]
      };

  static String encode(List<ShowPreview> shows) => json.encode(
        shows
            .map<Map<String, dynamic>>((music) => ShowPreview.toMap(music))
            .toList(),
      );

  static List<ShowPreview> decode(String shows) =>
      (json.decode(shows) as List<dynamic>)
          .map<ShowPreview>((item) => ShowPreview.fromJson(item))
          .toList();
}
