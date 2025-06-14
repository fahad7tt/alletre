// ignore_for_file: use_build_context_synchronously
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:alletre_app/view/widgets/auction%20form%20widgets/custom_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:intl/intl.dart';

class SwitchWithField extends StatelessWidget {
  final String label;
  final String leadingText;
  final ValueNotifier<bool> switchNotifier;
  final TextEditingController? textController;
  final String? labelText;
  final String? hintText;
  final bool isSchedulingEnabled; // Determines if scheduling fields are needed
  final TextEditingController? startDateController;
  final TextEditingController? startTimeController;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const SwitchWithField({
    super.key,
    required this.label,
    required this.leadingText,
    required this.switchNotifier,
    this.textController,
    this.labelText,
    this.hintText,
    this.isSchedulingEnabled = false,
    this.startDateController,
    this.startTimeController,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RichText(
              text: TextSpan(
                text: label,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: onSecondaryColor),
                children: const [
                  TextSpan(
                    text: ' (Optional)',
                    style: TextStyle(
                      color: greyColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: switchNotifier,
              builder: (context, isActive, child) {
                return FlutterSwitch(
                  value: isActive,
                  onToggle: (newValue) {
                    switchNotifier.value = newValue;
                    if (!newValue) {
                      textController?.clear();
                      startDateController?.clear();
                      startTimeController?.clear();
                    }
                  },
                  activeColor: primaryColor,
                  inactiveColor: Colors.grey[400]!,
                  toggleColor: secondaryColor,
                  toggleSize: 20.0,
                  width: 44.0,
                  height: 22.0,
                  padding: 2.0,
                );
              },
            ),
          ],
        ),
        Text(
          leadingText,
          style: const TextStyle(
            fontSize: 11,
            color: greyColor,
          ),
        ),
        const SizedBox(height: 10),
        ValueListenableBuilder<bool>(
          valueListenable: switchNotifier,
          builder: (context, isActive, child) {
            if (!isActive) return const SizedBox.shrink();
            return Column(
              children: [
                if (!isSchedulingEnabled && textController != null) ...[
                  TextFormField(
                    controller: textController,
                    keyboardType: keyboardType,
                    decoration: InputDecoration(
                      labelText: labelText,
                      labelStyle: const TextStyle(fontSize: 14),
                      hintText: hintText,
                      hintStyle: const TextStyle(fontSize: 12),
                      errorStyle: const TextStyle(color: errorColor, fontSize: 11, fontWeight: FontWeight.w500),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: errorColor),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: errorColor),
                      ),
                    ),
                    validator: (value) {
                      if (isActive) {
                        if (value == null || value.isEmpty) {
                          return "This field is required.";
                        }
                        if (validator != null) {
                          return validator!(value);
                        }
                      }
                      return null;
                    },
                  ),
                ],
                if (isSchedulingEnabled && startDateController != null) ...[
                  TextFormField(
                    controller: startDateController,
                    keyboardType: TextInputType.datetime,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Start Date and Time',
                      labelStyle: const TextStyle(fontSize: 14),
                      hintStyle: const TextStyle(fontSize: 12),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          // Select Date
                          DateTime? selectedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  textButtonTheme: TextButtonThemeData(
                                    style: TextButton.styleFrom(
                                      textStyle: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      foregroundColor:
                                          primaryColor, // For OK/Cancel buttons
                                    ),
                                  ),
                                  datePickerTheme: const DatePickerThemeData(
                                    headerHelpStyle: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    headerBackgroundColor: primaryColor,
                                    headerForegroundColor: secondaryColor,
                                    headerHeadlineStyle: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );

                          // Select Time
                          TimeOfDay? selectedTime =
                              await CustomTimePicker.showTimePickerDialog(
                                  context);
                          if (selectedTime != null) {
                            // Combine Date and Time
                            DateTime combinedDateTime = DateTime(
                              selectedDate!.year,
                              selectedDate.month,
                              selectedDate.day,
                              selectedTime.hour,
                              selectedTime.minute,
                            );

                            // Convert to UTC for backend
                            final utcDateTime = combinedDateTime.toUtc();
                            
                            // Store the ISO format for backend
                            final isoString = utcDateTime.toIso8601String();
                            startTimeController?.text = isoString;

                            // Show user-friendly format in the field (dd-MM-yyyy)
                            final displayFormat = DateFormat('dd-MM-yyyy, hh:mm a');
                            startDateController?.text = displayFormat.format(combinedDateTime);
                          }
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (isActive && (value == null || value.isEmpty)) {
                        return "Start date and time are required.";
                      }
                      return null;
                    },
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}
