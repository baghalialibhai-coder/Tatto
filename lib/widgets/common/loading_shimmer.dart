// // lib/widgets/common/loading_shimmer.dart
// import 'package:flutter/material.dart';
//
// class LoadingShimmer extends StatelessWidget {
//   final Widget child;
//
//   const LoadingShimmer({super.key, required this.child});
//
//   @override
//   Widget build(BuildContext context) {
//     return Shimmer.fromColors(
//       baseColor: Colors.grey.shade300,
//       highlightColor: Colors.grey.shade100,
//       child: child,
//     );
//   }
// }
//
// class ShimmerCard extends StatelessWidget {
//   const ShimmerCard({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Shimmer.fromColors(
//       baseColor: Colors.grey.shade300,
//       highlightColor: Colors.grey.shade100,
//       child: Card(
//         child: ListTile(
//           leading: CircleAvatar(backgroundColor: Colors.grey),
//           title: Container(height: 12, color: Colors.grey),
//           subtitle: Container(height: 8, color: Colors.grey),
//         ),
//       ),
//     );
//   }
// }