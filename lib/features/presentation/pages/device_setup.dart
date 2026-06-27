// ignore_for_file: use_build_context_synchronously

import 'package:collection/collection.dart';
import 'package:timer/common_libs.dart';
import 'package:timer/features/presentation/controller/device_setup_controller.dart';

@RoutePage()
class DeviceSetupScreen extends StatefulWidget {
  const DeviceSetupScreen({super.key});

  @override
  State<DeviceSetupScreen> createState() => _DeviceSetupScreenState();
}

class _DeviceSetupScreenState extends State<DeviceSetupScreen> {
  final tag = UniqueKey().toString();
  late final DeviceSetupController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(.new(), tag: tag);
  }

  @override
  void dispose() {
    Get.delete<DeviceSetupController>(tag: tag);
    super.dispose();
  }

  Future<void> testConnection() async {
    try {
      await controller.testConnection();
    } on AppExceptions catch (e) {
      context.showErrorSnackBar(e.message(context));
    } catch (e) {
      context.showErrorSnackBar(e.toString());
    }
  }

  Future<void> saveProfile() async {
    try {
      await controller.saveProfile();
      context.pushRoute(DashboardRoute());
    } on DeviceSetupControllerErrors catch (e) {
      if (e == DeviceSetupControllerErrors.fillAllFields) {
        context.showErrorSnackBar('Kindly fill in a name and url');
      }
    } on AppExceptions catch (e) {
      context.showErrorSnackBar(e.message(context));
    } catch (e) {
      context.showErrorSnackBar(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: buildAppBar(),
      body: GestureDetector(
        onTap: () => context.unfocus(),
        child: context.responsiveBuilder(
          phone: _MobileBody(
            identityCard: _Card(children: [buildName(), buildID()]),
            connectionCard: _Card(children: [buildUrl(), buildConnection()]),
            buttons: _buildMobileButtons(),
            font: context.font500S12,
          ),
          desktop: _DesktopBody(
            identityCard: _Card(children: [buildName(), buildID()]),
            connectionCard: _Card(children: [buildUrl(), buildConnection()]),
            buttons: _buildDesktopButtons(),
            font: context.font500S12,
          ),
        ),
      ),
    );
  }

  Widget _buildMobileButtons() => Column(
    children: [
      Obx(
        () => AppBtn.from(
          onPressed: saveProfile,
          isLoadingEnabled: controller.isSaving,
          text: 'Save Profile',
        ),
      ),
      verticalSpacer12,
      Obx(() {
        final isTesting = controller.isTesting;
        return AppBtn.from(
          onPressed: isTesting ? () {} : testConnection,
          isLoadingEnabled: isTesting,
          isOutlined: true,
          text: 'Test Connection',
        );
      }),
    ],
  );

  Widget _buildDesktopButtons() => Row(
    mainAxisAlignment: .end,
    children: [
      SizedBox(
        width: 200,
        child: Obx(() {
          final isTesting = controller.isTesting;
          return AppBtn.from(
            onPressed: isTesting ? () {} : testConnection,
            isLoadingEnabled: isTesting,
            isOutlined: true,
            text: 'Test Connection',
          );
        }),
      ),
      horizontalSpacer12,
      SizedBox(
        width: 200,
        child: Obx(
          () => AppBtn.from(
            onPressed: saveProfile,
            isLoadingEnabled: controller.isSaving,
            text: 'Save Profile',
          ),
        ),
      ),
    ],
  );

  Obx buildConnection() => Obx(
    () => _Field(
      icon: Icons.access_time_rounded,
      iconColor: context.$isLightMode
          ? const Color(0xFF3B6D11)
          : const Color(0xFF4CAF6A),
      iconBg: context.$isLightMode
          ? const Color(0xFFEAF3DE)
          : const Color(0xFF1A2E1A),
      label: 'Last seen',
      child: Text(
        controller.lastSeen != null
            ? _formatLastSeen(controller.lastSeen!).toUpperCase() +
                  (controller.isOnline
                      ? ' (DEVICE ONLINE)'
                      : ' (DEVICE OFFLINE)')
            : 'Never connected'.toUpperCase(),
        style: context.font500S14.copyWith(
          fontFamily: spaceGrotesk,
          fontSize: 18,
        ),
      ),
    ),
  );

  Obx buildUrl() => Obx(
    () => _Field(
      icon: Icons.wifi_rounded,
      iconColor: context.$isLightMode
          ? const Color(0xFF185FA5)
          : const Color(0xFF5B9BD5),
      iconBg: context.$isLightMode
          ? const Color(0xFFE6F1FB)
          : const Color(0xFF1A2A3A),
      label: 'Device IP address',
      trailing: _StatusDot(online: controller.isOnline),
      child: TextField(
        controller: controller.ipController,
        keyboardType: TextInputType.url,
        style: context.font600S14.copyWith(
          color: context.themedPrimaryColor,
          fontFamily: spaceGrotesk,
        ),
        decoration: const InputDecoration(hintText: 'Device IP address'),
      ),
    ),
  );

  IgnorePointer buildID() => IgnorePointer(
    ignoring: true,
    child: _Field(
      icon: Icons.devices_rounded,
      iconColor: Color(context.$isLightMode ? 0xFF6C63FF : 0xFF9B8FFF),
      iconBg: Color(context.$isLightMode ? 0xFFEEEDFE : 0xFF2D2A4A),
      label: 'Device ID',
      child: TextField(
        controller: controller.idController,
        decoration: const InputDecoration(hintText: 'Auto Generated'),
      ),
    ),
  );

  _Field buildName() => _Field(
    icon: Icons.label_outline_rounded,
    iconColor: Color(context.$isLightMode ? 0xFF6C63FF : 0xFF9B8FFF),
    iconBg: Color(context.$isLightMode ? 0xFFEEEDFE : 0xFF2D2A4A),
    label: 'Device name',
    child: TextField(
      controller: controller.nameController,
      decoration: const InputDecoration(hintText: 'Assign Name'),
    ),
  );

  AppBar buildAppBar() => AppBar(
    title: Text(
      'Device Setup',
      style: context.font700S22,
    ).fadeInAndMoveFromTop(),
    centerTitle: false,
  );

  String _formatLastSeen(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return 'Today, ${_hhmm(dt)}';
    if (diff.inDays == 1) return 'Yesterday, ${_hhmm(dt)}';
    return '${dt.day}/${dt.month}, ${_hhmm(dt)}';
  }

  String _hhmm(DateTime dt) =>
      '${dt.hour % 12 == 0 ? 12 : dt.hour % 12}:'
      '${dt.minute.toString().padLeft(2, '0')} '
      '${dt.hour < 12 ? 'AM' : 'PM'}';
}

class _MobileBody extends StatelessWidget {
  final Widget identityCard;
  final Widget connectionCard;
  final Widget buttons;
  final TextStyle font;

  const _MobileBody({
    required this.identityCard,
    required this.connectionCard,
    required this.buttons,
    required this.font,
  });

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.only(
      bottom: space32,
      left: space16,
      right: space16,
    ),
    children: [
      SectionHeader('Identity'),
      identityCard,
      verticalSpacer12,
      Text(
        'This label identifies the device across the network when multiple timers are connected.',
        style: font,
      ),
      SectionHeader('Timer Connection'),
      connectionCard,
      verticalSpacer12,
      Text(
        'Open the timer page in your browser on the same WiFi — the IP is in the address bar.',
        style: font,
      ),
      verticalSpacer24,
      buttons,
    ],
  );
}

class _DesktopBody extends StatelessWidget {
  final Widget identityCard;
  final Widget connectionCard;
  final Widget buttons;
  final TextStyle font;

  const _DesktopBody({
    required this.identityCard,
    required this.connectionCard,
    required this.buttons,
    required this.font,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 900),
      child: ListView(
        padding: const .symmetric(horizontal: space24, vertical: space32),
        children: [
          Row(
            crossAxisAlignment: .start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    SectionHeader('Identity'),
                    identityCard,
                    verticalSpacer12,
                    Text(
                      'This label identifies the device across the network when multiple timers are connected.',
                      style: font,
                    ),
                  ],
                ),
              ),
              horizontalSpacer20,

              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    SectionHeader('Timer Connection'),
                    connectionCard,
                    verticalSpacer12,
                    Text(
                      'Open the timer page in your browser on the same WiFi — the IP is in the address bar.',
                      style: font,
                    ),
                  ],
                ),
              ),
            ],
          ),
          verticalSpacer32,

          buttons,
        ],
      ),
    ),
  );
}

class _Card extends StatelessWidget {
  final List<Widget> children;
  const _Card({required this.children});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: context.cardBackgroundColor,
      borderRadius: .circular(space6),
      border: .all(color: context.cardBorderColor),
    ),
    child: Column(
      children: children
          .expandIndexed((i, w) => [if (i > 0) context.divider, w])
          .toList(),
    ),
  );
}

class _Field extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final Widget child;
  final Widget? trailing;

  const _Field({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(space12),
    child: Row(
      children: [
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(space6),
          ),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        horizontalSpacer8,
        Expanded(child: child),
        if (trailing != null) ...[horizontalSpacer8, trailing!],
      ],
    ),
  );
}

class _StatusDot extends StatelessWidget {
  final bool online;
  const _StatusDot({required this.online});

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 400),
    width: 8,
    height: 8,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: online ? const Color(0xFF4CAF6A) : const Color(0xFF48484A),
    ),
  );
}
