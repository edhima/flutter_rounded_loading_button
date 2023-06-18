library rounded_loading_button;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rounded_loading_button/src/button_state.dart';
import '/src/loader.dart';
import '/src/rounded_loading_button_controller.dart';
import 'package:rxdart/rxdart.dart';

/// Initialize class
class RoundedLoadingButton extends StatefulWidget {
  /// Button controller, now required
  final RoundedLoadingButtonController controller;

  /// The callback that is called when
  /// the button is tapped or otherwise activated.
  final Function? onPressed;

  /// The button's label
  final Widget child;

  /// The primary color of the button
  final Color? color;

  /// The vertical extent of the button.
  final double height;

  /// The horizontal extent of the button.
  final double width;

  /// The size of the CircularProgressIndicator
  final double loaderSize;

  /// The stroke width of the CircularProgressIndicator
  final double loaderStrokeWidth;

  /// Whether to trigger the animation on the tap event
  final bool animateOnTap;

  /// The color of the static icons
  final Color iconsColor;

  /// reset the animation after specified duration,
  /// use resetDuration parameter to set Duration, defaults to 15 seconds
  final bool resetAfterDuration;

  /// The curve of the shrink animation
  final Curve curve;

  /// The radius of the button border
  final double borderRadius;

  /// The duration of the button animation
  final Duration duration;

  /// The elevation of the raised button
  final double elevation;

  /// Duration after which reset the button
  final Duration resetDuration;

  /// The color of the button when it is in the error state
  final Color? errorColor;

  /// The color of the button when it is in the success state
  final Color? successColor;

  /// The color of the button when it is disabled
  final Color? disabledColor;

  /// The icon for the success state
  final IconData successIcon;

  /// The icon for the failed state
  final IconData failedIcon;

  /// The icon size
  final double? iconSize;

  /// The success and failed animation curve
  final Curve completionCurve;

  /// The duration of the success and failed animation
  final Duration completionDuration;

  /// The width of border
  final double? borderWidth;

  /// The color of border
  final Color? borderColor;

  Duration get _borderDuration {
    return Duration(milliseconds: (duration.inMilliseconds / 2).round());
  }

  /// initialize constructor
  const RoundedLoadingButton({
    Key? key,
    required this.controller,
    required this.onPressed,
    required this.child,
    this.color = Colors.lightBlue,
    this.height = 50,
    this.width = 300,
    this.loaderSize = 24.0,
    this.loaderStrokeWidth = 2.0,
    this.animateOnTap = true,
    this.iconsColor = Colors.white,
    this.borderRadius = 35,
    this.elevation = 2,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeInOutCirc,
    this.errorColor = Colors.red,
    this.successColor,
    this.resetDuration = const Duration(seconds: 15),
    this.resetAfterDuration = false,
    this.successIcon = Icons.check,
    this.failedIcon = Icons.close,
    this.iconSize,
    this.completionCurve = Curves.elasticOut,
    this.completionDuration = const Duration(milliseconds: 1000),
    this.disabledColor,
    this.borderColor,
    this.borderWidth,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => RoundedLoadingButtonState();
}

/// Class implementation
class RoundedLoadingButtonState extends State<RoundedLoadingButton>
    with TickerProviderStateMixin {
  late AnimationController _buttonController;
  late AnimationController _borderController;
  late AnimationController _checkButtonController;

  late Animation _squeezeAnimation;
  late Animation _bounceAnimation;
  late Animation _borderAnimation;

  final _state = BehaviorSubject<ButtonState>.seeded(ButtonState.idle);

  @override
  Widget build(BuildContext context) {
    Widget _check = Container(
      alignment: FractionalOffset.center,
      decoration: BoxDecoration(
        color: widget.successColor ?? widget.color,
        borderRadius: BorderRadius.all(Radius.circular(widget.borderRadius)),
        border: widget.borderColor != null
              ? Border.all(
                  color: widget.borderColor!,
                  width: widget.borderWidth ?? 1,
                )
              : null
      ),
      width: _bounceAnimation.value,
      height: _bounceAnimation.value,
      child: _bounceAnimation.value > 20
          ? Icon(
              widget.successIcon,
              color: widget.iconsColor,
              size: widget.iconSize,
            )
          : null,
    );

    Widget _cross = Container(
      alignment: FractionalOffset.center,
      decoration: BoxDecoration(
          color: widget.errorColor,
          borderRadius: BorderRadius.all(Radius.circular(widget.borderRadius)),
          border: widget.borderColor != null
              ? Border.all(
                  color: widget.borderColor!,
                  width: widget.borderWidth ?? 1,
                )
              : null),
      width: _bounceAnimation.value,
      height: _bounceAnimation.value,
      child: _bounceAnimation.value > 20
          ? Icon(
              widget.failedIcon,
              color: widget.iconsColor,
              size: widget.iconSize,
            )
          : null,
    );

    return SizedBox(
      height: widget.height,
      child: Center(
        child: _state.value == ButtonState.error
            ? _cross
            : _state.value == ButtonState.success
                ? _check
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.color,
                      disabledBackgroundColor: widget.disabledColor,
                      minimumSize: Size(_squeezeAnimation.value, widget.height),
                      shape: RoundedRectangleBorder(
                        borderRadius: _borderAnimation.value,
                        side: (widget.borderColor != null)
                            ? BorderSide(
                                width: widget.borderWidth ?? 1,
                                color: widget.borderColor!)
                            : BorderSide.none,
                      ),
                      elevation: widget.elevation,
                      padding: const EdgeInsets.all(0),
                    ),
                    onPressed: widget.onPressed == null ? null : _btnPressed,
                    child: StreamBuilder(
                      stream: _state,
                      builder: (context, snapshot) {
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: snapshot.data == ButtonState.loading
                              ? Loader(
                                  loaderStrokeWidth: widget.loaderStrokeWidth,
                                  loaderSize: widget.loaderSize,
                                  iconsColor: widget.iconsColor,
                                )
                              : widget.child,
                        );
                      },
                    ),
                  ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _buttonController =
        AnimationController(duration: widget.duration, vsync: this);

    _checkButtonController =
        AnimationController(duration: widget.completionDuration, vsync: this);

    _borderController =
        AnimationController(duration: widget._borderDuration, vsync: this);

    _bounceAnimation = Tween<double>(begin: 0, end: widget.height).animate(
      CurvedAnimation(
        parent: _checkButtonController,
        curve: widget.completionCurve,
      ),
    );
    _bounceAnimation.addListener(() {
      setState(() {});
    });

    _squeezeAnimation =
        Tween<double>(begin: widget.width, end: widget.height).animate(
      CurvedAnimation(parent: _buttonController, curve: widget.curve),
    );

    _squeezeAnimation.addListener(() {
      setState(() {});
    });

    _borderAnimation = BorderRadiusTween(
      begin: BorderRadius.circular(widget.borderRadius),
      end: BorderRadius.circular(widget.height),
    ).animate(_borderController);

    _borderAnimation.addListener(() {
      setState(() {});
    });

    // There is probably a better way of doing this...
    _state.stream.listen((event) {
      if (!mounted) return;
      widget.controller.state.sink.add(event);
    });

    widget.controller.addListeners(_start, _stop, _success, _error, _reset);
  }

  @override
  void dispose() {
    _buttonController.dispose();
    _checkButtonController.dispose();
    _borderController.dispose();
    _state.close();
    super.dispose();
  }

  Future<void> _btnPressed() async {
    if (widget.animateOnTap) {
      _start();
    } else {
      if (widget.onPressed != null) {
        await widget.onPressed!();
      }
    }
  }

  Future<void> _start() async {
    if (!mounted) return;
    _state.sink.add(ButtonState.loading);
    _borderController.forward();
    _buttonController.forward();
    await widget.onPressed!();
  }

  void _stop() {
    if (!mounted) return;
    _state.sink.add(ButtonState.idle);
    _buttonController.reverse();
    _borderController.reverse();
  }

  void _success() {
    if (!mounted) return;
    _state.sink.add(ButtonState.success);
    _checkButtonController.forward();
    if (widget.resetAfterDuration) _reset();
  }

  void _error() {
    if (!mounted) return;
    _state.sink.add(ButtonState.error);
    _checkButtonController.forward();
    if (widget.resetAfterDuration) _reset();
  }

  void _reset() async {
    if (!mounted) return;
    if (widget.resetAfterDuration) await Future.delayed(widget.resetDuration);
    _state.sink.add(ButtonState.idle);
    unawaited(_buttonController.reverse());
    unawaited(_borderController.reverse());
    _checkButtonController.reset();
  }
}


