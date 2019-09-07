import 'dart:convert';
import 'dart:io';

import 'package:coolweather/select_county.dart';
import 'package:coolweather/weather_mode.dart';
import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeatherDetail extends StatefulWidget {
  WeatherDetail({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _WeatherDetailState();
  }
}

class _WeatherDetailState extends State<WeatherDetail> {
  String countyName;

  String weatherId;

  String bingImgUrl = '';

  WeatherMode weatherMode;

  _WeatherDetailState();

  @override
  void initState() {
    super.initState();

    _queryImage();

    _initData().then((bool) {
      if (bool) {
        _queryWeather();
      } else {
        _selectCounty();
      }
    });
  }

  _selectCounty() {
    Navigator.push(
            context, new MaterialPageRoute(builder: (context) => SelectCounty()))
        .then((bool) {
      if (bool) {
        _initData().then((bool) {
          if (bool) {
            _queryWeather();
          } else {
            _selectCounty();
          }
        });
      }
    });
  }

  Future<bool> _initData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    countyName = prefs.getString('countyName');
    weatherId = prefs.getString('weatherId');
    if (!isEmpty(countyName) && !isEmpty(weatherId)) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return mainLayout(context);
  }

  Widget mainLayout(BuildContext context) {
    return Scaffold(
      body: Container(
          padding: EdgeInsets.fromLTRB(16, 25, 16, 0),
          child: RefreshIndicator(
            onRefresh: _queryWeather,
            child: ListView(
              children: <Widget>[
                _titleLayout(),
                _tempLayout(),
                _weatherLayout(),
                _forecastLayout(),
                _aqiLayout(),
                _suggestionLayout(),
              ],
            ),
          ),
          decoration: BoxDecoration(
              image: DecorationImage(
            image: NetworkImage(bingImgUrl),
            fit: BoxFit.fitHeight,
          ))),
    );
  }

  Widget _titleLayout() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        IconButton(
          icon: Image(image: AssetImage("image/ic_home.png"), width: 26.0),
          onPressed: _selectCounty,
        ),
        Text(
          countyName != null ? countyName : "",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            decoration: TextDecoration.none,
          ),
        ),
        Text(
          weatherMode != null
              ? weatherMode.HeWeather[0].update.loc.substring(11)
              : "",
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            decoration: TextDecoration.none,
          ),
        )
      ],
    );
  }

  Widget _tempLayout() {
    return Container(
      padding: EdgeInsets.only(top: 35),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Text(
            (weatherMode != null ? weatherMode.HeWeather[0].now.tmp : "0") +
                "℃",
            style: TextStyle(
              color: Colors.white,
              fontSize: 50,
              decoration: TextDecoration.none,
            ),
          )
        ],
      ),
    );
  }

  Widget _weatherLayout() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Text(
          weatherMode != null ? weatherMode.HeWeather[0].now.cond_txt : "未知",
          style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              decoration: TextDecoration.none),
        )
      ],
    );
  }

  Widget _forecastLayout() {
    return Container(
      margin: EdgeInsets.only(top: 20),
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(24, 10, 0, 0),
            child: Row(
              children: <Widget>[
                Text("预报",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        decoration: TextDecoration.none))
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(bottom: 10),
            child: _getForecastRow(),
          )
        ],
      ),
      decoration: BoxDecoration(color: Colors.black38),
    );
  }

  Widget _getForecastRow() {
    List<Widget> forecastRow = new List();
    for (int i = 0;
        weatherMode != null &&
            i < weatherMode.HeWeather[0].daily_forecast.length;
        i++) {
      Daily daily = weatherMode.HeWeather[0].daily_forecast.elementAt(i);
      forecastRow.add(Container(
        padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Row(
          children: <Widget>[
            _textLayout(daily.date),
            _textLayout(daily.cond.txt_d),
            _textLayout(daily.tmp.max),
            _textLayout(daily.tmp.min),
          ],
          mainAxisAlignment: MainAxisAlignment.spaceAround,
        ),
      ));
    }

    return Column(
      children: forecastRow,
    );
  }

  Widget _textLayout(String content) {
    return Text(content,
        style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            decoration: TextDecoration.none));
  }

  Widget _aqiLayout() {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
      padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: Text("空气质量",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        decoration: TextDecoration.none)),
              )
            ],
          ),
          Row(
            children: <Widget>[
              Column(children: <Widget>[
                Text(
                  weatherMode != null
                      ? weatherMode.HeWeather[0].aqi.city.aqi
                      : "",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      decoration: TextDecoration.none),
                ),
                Text(
                  'AQI指数',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      decoration: TextDecoration.none),
                )
              ]),
              Column(children: <Widget>[
                Text(
                    weatherMode != null
                        ? weatherMode.HeWeather[0].aqi.city.pm25
                        : "",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        decoration: TextDecoration.none)),
                Text('PM2.5指数',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        decoration: TextDecoration.none))
              ])
            ],
            mainAxisAlignment: MainAxisAlignment.spaceAround,
          )
        ],
      ),
      decoration: BoxDecoration(color: Colors.black38),
    );
  }

  Widget _suggestionLayout() {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
      padding: EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                '生活建议',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    decoration: TextDecoration.none),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.start,
          ),
          _suggestContentLayout(weatherMode != null
              ? weatherMode.HeWeather[0].suggestion.comf.txt
              : ""),
          _suggestContentLayout(weatherMode != null
              ? weatherMode.HeWeather[0].suggestion.sport.txt
              : ""),
          _suggestContentLayout(weatherMode != null
              ? weatherMode.HeWeather[0].suggestion.cw.txt
              : ""),
        ],
      ),
      decoration: BoxDecoration(color: Colors.black38),
    );
  }

  Widget _suggestContentLayout(String content) {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: Text(
        content,
        style: TextStyle(
            color: Colors.white, fontSize: 14, decoration: TextDecoration.none),
      ),
    );
  }

  _queryImage() async {
    String bingPicUrl = "http://guolin.tech/api/bing_pic";
    var httpClient = new HttpClient();
    try {
      var request = await httpClient.getUrl(Uri.parse(bingPicUrl));
      var response = await request.close();
      if (response.statusCode == HttpStatus.OK) {
        var imgUrl = await response.transform(utf8.decoder).join();
        setState(() {
          bingImgUrl = imgUrl;
          print(bingImgUrl);
        });
      }
    } catch (ignore) {}
  }

  Future<Null> _queryWeather() async {
    var url = 'http://guolin.tech/api/weather?cityid=' +
        '$weatherId' +
        '&key=bc0418b57b2d4918819d3974ac1285d9';

    var httpClient = new HttpClient();
    try {
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();
      if (response.statusCode == HttpStatus.OK) {
        var json = await response.transform(utf8.decoder).join();
        Map data = jsonDecode(json);
        setState(() {
          weatherMode = new WeatherMode.fromJson(data);
        });
      }
    } catch (ignore) {}
  }
}
