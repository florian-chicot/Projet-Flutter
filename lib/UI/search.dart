import 'package:flutter/material.dart';

import 'dart:async';
import 'dart:convert';

import '../Model/country.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';

Future<List<Country>> fetchCountries(String searchValueCountry) async {
  final response = await http.get(Uri.parse('https://restcountries.com/v3.1/name/${Uri.encodeFull(searchValueCountry)}'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response, then parse the JSON.
    List<dynamic> countriesJson = json.decode(response.body);
    List<Country> countries = countriesJson.map((c) => Country.fromJson(c)).toList();
    return countries;
  }else {
    throw Exception('Failed to load countries. Error code: ${response.statusCode}');
  }
}

class Search extends StatefulWidget {
  final String searchValueCountry;
  Search(this.searchValueCountry);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  late Future<List<Country>> _countries;

  @override
  void initState() {
    super.initState();
    _countries = fetchCountries(widget.searchValueCountry);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Results'),
      ),
      body: FutureBuilder<List<Country>>(
        future: _countries,
        builder: (context, countries) {
          if (countries.hasData) {
            return ListView.builder(
              itemCount: countries.data!.length,
              itemBuilder: (context, index) {
                final country = countries.data![index];
                return ListTile(
                  title: Text(country.name),
                  subtitle: Text(country.officialName),
                  leading: SvgPicture.network(country.flag),
                );
              },
            );
          } else if (countries.hasError) {
            return Text("${countries.error}");
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}