import 'package:flutter/material.dart';

class NetworkCircleAvatar extends StatelessWidget {
  final String? imgUrl;
  final double? radius;

  const NetworkCircleAvatar({
    this.imgUrl,
    this.radius,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey[300],
      child: ClipOval(
        child: Image.network(
          imgUrl ?? '',
          width: radius == null ? null : radius! * 2,
          height: radius == null ? null : radius! * 2,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.person,
              size: radius,
              color: Colors.grey[600],
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
        ),
      ),
    );
  }
}
