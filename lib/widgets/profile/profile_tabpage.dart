import 'package:fashionet_provider/models/models.dart';
import 'package:flutter/material.dart';

class ProfileTabPage extends StatelessWidget {
  final Profile profile;

  const ProfileTabPage({Key key, @required this.profile}) : super(key: key);

  Profile get _profile => profile;

  Widget _buildPostPriceTag({@required BuildContext context}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          height: 30.0,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(15.0),
                bottomLeft: Radius.circular(15.0)),
            // borderRadius: BorderRadius.circular(25.0),
          ),
          child: Text(
            '${_profile.followersCount} ${_profile.followersCount > 1 ? 'followers' : 'follower'}',
            style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 16.0,
                fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final double _deviceWidth = MediaQuery.of(context).size.width;

    final double _contentWidthPadding =
        _deviceWidth > 450.0 ? _deviceWidth - 450.0 : 30.0;

    return SliverToBoxAdapter(
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: 20.0,
            horizontal: _contentWidthPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '${_profile.firstName.trim()} ${_profile.lastName.trim()}',
                // 'Ella\'s Fashion Decore',
                style: TextStyle(
                    color: Theme.of(context).accentColor,
                    fontWeight: FontWeight.bold),
              ),
              // SizedBox(height: 5.0),
              Text(
                '${_profile.businessName}',
                style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.w900),
              ),
              _buildPostPriceTag(context: context),
              SizedBox(height: 20.0),
              Text(
                'Contacts',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
              ),
              SizedBox(height: 10.0),
              Row(
                children: <Widget>[
                  Icon(Icons.access_time, size: 15.0),
                  SizedBox(width: 5.0),
                  Expanded(child: Text('Mon - Fri (9.00am - 6.00pm)')),
                ],
              ),
              SizedBox(height: 5.0),
              Row(
                children: <Widget>[
                  Icon(Icons.phone_android, size: 15.0),
                  SizedBox(width: 5.0),
                  Text('${_profile.phoneNumber}'),
                  _profile.otherPhoneNumber.isEmpty
                      ? Container()
                      : Text(' ,${_profile.otherPhoneNumber}'),
                ],
              ),
              SizedBox(height: 5.0),
              Row(
                children: <Widget>[
                  Icon(Icons.location_on, size: 15.0),
                  SizedBox(width: 5.0),
                  Expanded(child: Text('${_profile.businessLocation}')),
                ],
              ),
              SizedBox(height: 20.0),
              Container(
                height: 150.0,
                width: double.maxFinite,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage('assets/images/map_img.jpg'))),
              ),
              SizedBox(height: 30.0),
              Text(
                'Detail Summary',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
              ),
              SizedBox(height: 10.0),
              Text(
                '${_profile.businessDescription}',
                textAlign: TextAlign.justify,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
