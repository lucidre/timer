// ignore_for_file: use_build_context_synchronously

import 'package:timer/common_libs.dart';
import 'package:timer/features/models/schedule/schedule.dart';
import 'package:timer/features/presentation/controller/schedule_form_controller.dart';

final scheduleFormScreenDelete = 'delete';

@RoutePage()
class ScheduleFormScreen extends StatefulWidget {
  final Schedule? schedule;
  final DateTime? previousEndTime;

  const ScheduleFormScreen({super.key, this.schedule, this.previousEndTime});

  @override
  State<ScheduleFormScreen> createState() => _ScheduleFormScreenState();
}

class _ScheduleFormScreenState extends State<ScheduleFormScreen> {
  final tag = UniqueKey().toString();
  late final ScheduleFormController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(
      .new(existing: widget.schedule, previous: widget.previousEndTime),
      tag: tag,
    );
  }

  @override
  void dispose() {
    Get.delete<ScheduleFormController>(tag: tag);
    super.dispose();
  }

  // ─── Pickers (unchanged) ─────────────────────────────────────────────────────

  void pickStartDate() async {
    AppHaptics.selectionClick();
    final picked = await showDatePicker(
      context: context,
      initialDate: controller.startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => context.dateTheme(child!),
    );
    if (picked != null) controller.updateStartDate(picked);
  }

  void pickEndDate() async {
    AppHaptics.selectionClick();
    final picked = await showDatePicker(
      context: context,
      initialDate: controller.endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => context.dateTheme(child!),
    );
    if (picked != null) controller.updateEndDate(picked);
  }

  void pickStartTime() async {
    AppHaptics.selectionClick();
    final startDate = controller.startDate;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(startDate),
      builder: (context, child) => context.dateTheme(child!),
    );
    if (picked != null) {
      controller.updateStartTime(
        DateTime(
          startDate.year,
          startDate.month,
          startDate.day,
          picked.hour,
          picked.minute,
        ),
      );
    }
  }

  void pickEndTime() async {
    AppHaptics.selectionClick();
    final endDate = controller.endDate;
    final startDate = controller.startDate;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(endDate),
      builder: (context, child) => context.dateTheme(child!),
    );
    if (picked != null) {
      final newEnd = DateTime(
        endDate.year,
        endDate.month,
        endDate.day,
        picked.hour,
        picked.minute,
      );
      if (newEnd.isBefore(startDate)) {
        context.showErrorSnackBar('End time must be after the start time.');
        return;
      }
      controller.updateEndTime(newEnd);
    }
  }

  Future<void> saveSchedule() async {
    context.unfocus();
    try {
      final schedule = controller.saveSchedule();
      context.maybePop(schedule);
    } on ScheduleFormControllerErrors catch (_) {
    } on AppExceptions catch (e) {
      context.showErrorSnackBar(e.message(context));
    } catch (e) {
      context.showErrorSnackBar('An error occurred, please retry.');
    }
  }

  Future<void> deleteSchedule() async {
    context.unfocus();
    try {
      context.maybePop(scheduleFormScreenDelete);
    } on ScheduleFormControllerErrors catch (_) {
    } on AppExceptions catch (e) {
      context.showErrorSnackBar(e.message(context));
    } catch (e) {
      context.showErrorSnackBar('An error occurred, please retry.');
    }
  }

  // ─── Root ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: buildAppBar(),
      body: GestureDetector(
        onTap: () => context.unfocus(),
        child: context.responsiveBuilder(
          phone: _MobileBody(
            title: buildTitle(),
            startSection: buildStartSection(),
            endDetailSwitch: buildEndDetailSwitch(),
            endSection: buildEndSection(),
            warningBox: _buildWarningBox(),
            saveButton: _buildSaveButton(),
            deleteButton: _buildDeleteBlock(),
          ),
          desktop: _DesktopBody(
            title: buildTitle(),
            startSection: buildStartSection(),
            endDetailSwitch: buildEndDetailSwitch(),
            endSection: buildEndSection(),
            warningBox: _buildWarningBox(),
            saveButton: _buildSaveButton(),
            deleteButton: _buildDeleteBlock(),
          ),
        ),
      ),
    );
  }

  // ─── Shared widgets ───────────────────────────────────────────────────────────

  Widget _buildSaveButton() => AppBtn.from(
    onPressed: saveSchedule,
    text: controller.isEditMode ? 'Update Block' : 'Save Block',
  );
  Widget? _buildDeleteBlock() => !controller.isEditMode
      ? null
      : AppBtn.from(
          onPressed: deleteSchedule,
          text: 'Delete Block',
          bgColor: destructive600,
        );

  Row buildEndDetailSwitch() {
    return Row(
      children: [
        Expanded(child: const SectionHeader('END DETAILS')),
        Obx(() {
          final mode = controller.durationMode;
          return ToggleButtons(
            isSelected: [mode, !mode],
            onPressed: (index) => controller.durationMode = index == 0,
            borderRadius: BorderRadius.circular(space6),
            constraints: const BoxConstraints(minHeight: 32, minWidth: 80),
            color: context.textColor,
            selectedColor: lightColor,
            fillColor: context.themedPrimaryColor,
            borderColor: context.textColor,
            selectedBorderColor: context.textColor,
            children: const [
              Text(
                'Duration',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: satoshi,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Time',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: satoshi,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          );
        }).fadeInAndMoveFromBottom(),
      ],
    );
  }

  Container buildEndSection() {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        border: Border.all(color: context.cardBorderColor),
        borderRadius: BorderRadius.circular(space6),
      ),
      child: Obx(
        () => controller.durationMode
            ? _buildDurationPicker()
            : Column(
                children: [
                  ListTile(
                    title: Text('End Date', style: context.font600S14),
                    trailing: Text(
                      $appUtil.formatDateFull(controller.startDate),
                      style: context.font600S14.copyWith(
                        color: context.themedPrimaryColor,
                      ),
                    ),
                    onTap: pickStartDate,
                  ).fadeInAndMoveFromBottom(),
                  context.divider,
                  ListTile(
                    title: Text('End Time', style: context.font600S14),
                    trailing: Text(
                      $appUtil.formatTime(controller.endDate),
                      style: context.font600S14.copyWith(
                        color: context.themedPrimaryColor,
                      ),
                    ),
                    onTap: pickEndTime,
                  ).fadeInAndMoveFromBottom(),
                ],
              ),
      ),
    );
  }

  Container buildStartSection() {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        border: Border.all(color: context.cardBorderColor),
        borderRadius: BorderRadius.circular(space6),
      ),
      child: Obx(() {
        return Column(
          children: [
            ListTile(
              title: Text('Start Date', style: context.font600S14),
              trailing: Text(
                $appUtil.formatDateFull(controller.startDate),
                style: context.font600S14.copyWith(
                  color: context.themedPrimaryColor,
                ),
              ),
              onTap: pickStartDate,
            ).fadeInAndMoveFromBottom(),
            context.divider,
            ListTile(
              title: Text('Start Time', style: context.font600S14),
              trailing: Text(
                $appUtil.formatTime(controller.startDate),
                style: context.font600S14.copyWith(
                  color: context.themedPrimaryColor,
                ),
              ),
              onTap: pickStartTime,
            ).fadeInAndMoveFromBottom(),
            if (controller.previous != null) ...[
              context.divider,
              InkWell(
                onTap: controller.snapToPreviousEndTime,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.center,
                  child: Text(
                    'Snap to Previous Block End Time',
                    style: context.font600S14.copyWith(
                      color: context.$isDarkMode ? success300 : success600,
                    ),
                  ),
                ),
              ).fadeInAndMoveFromBottom(),
            ],
          ],
        );
      }),
    );
  }

  Form buildTitle() {
    return Form(
      key: controller.formKey,
      child: TextFormField(
        controller: controller.nameController,
        decoration: const InputDecoration(hintText: 'Block Name'),
        textInputAction: TextInputAction.done,
        keyboardType: TextInputType.name,
        validator: (value) =>
            (value?.isEmpty ?? true) ? 'Please provide a name' : null,
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      centerTitle: false,
      leading: BackButton(color: context.textColor),
      title: Text(
        controller.isEditMode ? 'Edit Block' : 'Add Block',
        style: context.font700S22,
      ).fadeInAndMoveFromTop(),
    );
  }

  Widget _buildDurationPicker() {
    final duration = controller.duration.inMinutes;
    final raw = [5, 10, 15, 30, 45, 60];

    if (!raw.contains(duration)) {
      raw.add(duration);
      raw.sort();
    }

    return Padding(
      padding: const EdgeInsets.all(space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Duration', style: context.font600S16),
              const Spacer(),
              Text('Selected: ', style: context.font600S16),
              Text(
                '$duration mins',
                style: context.font600S16.copyWith(
                  color: context.themedPrimaryColor,
                ),
              ),
            ],
          ).fadeInAndMoveFromTop(),
          verticalSpacer12,
          context.divider,
          verticalSpacer12,
          Wrap(
            spacing: space12,
            runSpacing: space12,
            children: raw
                .map(
                  (mins) => ActionChip(
                    label: Text(
                      '$mins m',
                      style: TextStyle(
                        fontFamily: spaceGrotesk,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(space6),
                    ),
                    backgroundColor: duration == mins
                        ? context.themedPrimaryColor
                        : context.textColor,
                    labelStyle: TextStyle(
                      color: duration == mins
                          ? lightColor
                          : context.backgroundColor,
                    ),
                    onPressed: () {
                      AppHaptics.selectionClick();
                      controller.setDuration(mins);
                    },
                  ).fadeInAndMoveFromRight(),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningBox() {
    final isEditMode = controller.isEditMode;
    return Container(
      padding: const EdgeInsets.all(space16),
      decoration: BoxDecoration(
        color: warning500.withValues(alpha: 0.15),
        border: Border.all(color: warning500.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: warning500, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isEditMode
                  ? 'Modifying this block will push all subsequent blocks forward. If this causes overlaps, other times will be dynamically resolved.'
                  : 'Adding a block adjusts the schedule continuously. It will be synced instantly across all devices on the network.',
              style: context.font600S14.copyWith(
                color: warning500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Layout shells ────────────────────────────────────────────────────────────

class _MobileBody extends StatelessWidget {
  final Widget title;
  final Widget startSection;
  final Widget endDetailSwitch;
  final Widget endSection;
  final Widget warningBox;
  final Widget saveButton;
  final Widget? deleteButton;

  const _MobileBody({
    required this.title,
    required this.startSection,
    required this.endDetailSwitch,
    required this.endSection,
    required this.warningBox,
    required this.saveButton,
    required this.deleteButton,
  });

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    physics: const BouncingScrollPhysics(),
    padding: const EdgeInsets.symmetric(horizontal: space16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        verticalSpacer12,
        title,
        verticalSpacer12,
        SectionHeader('Start Details'),
        startSection,
        verticalSpacer12,
        endDetailSwitch,
        verticalSpacer12,
        endSection,
        verticalSpacer24,
        warningBox,
        verticalSpacer24,
        saveButton,
        if (deleteButton != null) ...[verticalSpacer16, deleteButton!],
      ],
    ),
  );
}

class _DesktopBody extends StatelessWidget {
  final Widget title;
  final Widget startSection;
  final Widget endDetailSwitch;
  final Widget endSection;
  final Widget warningBox;
  final Widget saveButton;
  final Widget? deleteButton;

  const _DesktopBody({
    required this.title,
    required this.startSection,
    required this.endDetailSwitch,
    required this.endSection,
    required this.warningBox,
    required this.saveButton,
    required this.deleteButton,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 900),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: space24,
          vertical: space24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Full-width block name ───────────────────────────────────
            title,
            verticalSpacer24,

            // ── Start + End side-by-side ────────────────────────────────
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left — Start Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SectionHeader('Start Details'),
                        verticalSpacer12,
                        startSection,
                      ],
                    ),
                  ),
                  horizontalSpacer20,
                  // Right — End Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [endDetailSwitch, verticalSpacer12, endSection],
                    ),
                  ),
                ],
              ),
            ),

            verticalSpacer24,

            warningBox,
            verticalSpacer24,

            Align(
              alignment: .centerRight,
              child: Row(
                mainAxisSize: .min,
                children: [
                  saveButton,
                  if (deleteButton != null) ...[
                    horizontalSpacer16,
                    deleteButton!,
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
