import 'package:cached_network_image/cached_network_image.dart';
import 'package:fashionet_provider/blocs/blocs.dart';
import 'package:fashionet_provider/models/models.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileSubscriptionCard extends StatefulWidget {
  final Profile profile;

  const ProfileSubscriptionCard({Key key, @required this.profile})
      : super(key: key);

  @override
  _ProfileSubscriptionCardState createState() =>
      _ProfileSubscriptionCardState();
}

class _ProfileSubscriptionCardState extends State<ProfileSubscriptionCard> {
  Profile get _profile => widget.profile;

  Widget _buildUnfollowButton() {
    return Consumer<PostBloc>(
        builder: (BuildContext context, PostBloc postBloc, Widget child) {
      bool _isFollowingStatus = _profile.isFollowing;

      return Material(
        elevation: 5.0,
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(10.0),
        child: InkWell(
          onTap: () {
            postBloc.toggleFollowProfilePageStatus(
                currentPostProfile: _profile);

            setState(() => _isFollowingStatus = !_profile.isFollowing);
            print('Unfollow ${_profile.isFollowing} page');
          },
          borderRadius: BorderRadius.circular(10.0),
          child: Container(
            decoration:
                BoxDecoration(borderRadius: BorderRadius.circular(10.0)),
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
            child: Text(
              _isFollowingStatus ? 'Unfollow Page' : 'Follow Page',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTitleListTile({@required BuildContext context}) {
    return ListTile(
      leading: _profile != null && _profile.profileImageUrl.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: '${_profile.profileImageUrl}',
              placeholder: (context, imageUrl) =>
                  Center(child: CircularProgressIndicator(strokeWidth: 2.0)),
              errorWidget: (context, imageUrl, error) =>
                  Center(child: Icon(Icons.error)),
              imageBuilder: (BuildContext context, ImageProvider image) {
                return Container(
                  height: 50.0,
                  width: 50.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(image: image, fit: BoxFit.cover),
                  ),
                );
              },
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(25.0),
              child: Image.asset('assets/avatars/ps-avatar.png',
                  fit: BoxFit.cover),
            ),
      title: Text('${_profile.businessName}',
          style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.location_on, size: 15.0),
          SizedBox(width: 5.0),
          Flexible(child: Text('${_profile.businessLocation}')),
        ],
      ),
      trailing: _buildUnfollowButton(),
    );
  }

  Widget _buildFollowersCountTag({@required BuildContext context}) {
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
                topLeft: Radius.circular(15.0),
                bottomLeft: Radius.circular(15.0)),
            // borderRadius: BorderRadius.circular(25.0),
          ),
          child: Text(
            '${_profile.followersCount} ${_profile.followersCount > 1 ? 'followers' : 'follower'}',
            style: TextStyle(
                color: Theme.of(context).accentColor,
                fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionListTile({@required BuildContext context}) {
    return ListTile(
      title: Text(
        'Description',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        '${_profile.businessDescription}',
        overflow: TextOverflow.ellipsis,
      ),
      trailing: _buildFollowersCountTag(context: context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Card(
        child: Column(
          children: <Widget>[
            _buildTitleListTile(context: context),
            _buildDescriptionListTile(context: context),
          ],
        ),
      ),
    );
  }
}
