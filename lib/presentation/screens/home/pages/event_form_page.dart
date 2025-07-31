import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'dart:io';

import 'package:rovify/presentation/blocs/event/event_form_bloc.dart';

class EventFormScreen1 extends StatefulWidget {
  const EventFormScreen1({super.key});

  @override
  State<EventFormScreen1> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen1> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Text controllers for input fields
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  @override
  void dispose() {
    // Clean up controllers when widget is disposed
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background to white
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Create New Event',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: BlocListener<EventFormBloc, EventFormState>(
        listener: (context, state) {
          // Handle different states with appropriate user feedback
          if (state is EventFormSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          } else if (state is EventFormError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event Title Input
                _buildSectionTitle('Event Details'),
                const SizedBox(height: 12),
                _buildTextFormField(
                  controller: _titleController,
                  label: 'Event Title',
                  hint: 'Enter your event title',
                  validator: (value) => value?.isEmpty == true ? 'Event title is required' : null,
                ),
                const SizedBox(height: 16),

                // Event Type Dropdown
                BlocBuilder<EventFormBloc, EventFormState>(
                  builder: (context, state) {
                    final currentState = state is EventFormUpdated ? state : null;
                    return _buildDropdownField<String>(
                      value: currentState?.type ?? 'in-person',
                      label: 'Event Type',
                      items: const ['in-person', 'virtual', 'hybrid'],
                      onChanged: (value) {
                        context.read<EventFormBloc>().add(UpdateEventType(value!));
                      },
                    );
                  },
                ),
                
                const SizedBox(height: 16),

                // Location Input (changes based on event type)
                BlocBuilder<EventFormBloc, EventFormState>(
                  builder: (context, state) {
                    final isVirtual = state is EventFormUpdated && state.type == 'virtual';
                    return _buildTextFormField(
                      controller: _locationController,
                      label: isVirtual ? 'Event Link' : 'Location',
                      hint: isVirtual 
                          ? 'e.g., https://meet.google.com/xyz'
                          : 'e.g., Accra Sports Stadium, Ghana',
                      validator: (value) => value?.isEmpty == true ? 'Location is required' : null,
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Category Dropdown
                BlocBuilder<EventFormBloc, EventFormState>(
                  builder: (context, state) {
                    final currentState = state is EventFormUpdated ? state : null;
                    return _buildDropdownField<String>(
                      value: currentState?.category ?? 'Music',
                      label: 'Category',
                      items: const ['Music', 'Nightlife', 'Gaming', 'Sports', 'Health', 'Comedy', 'Cinema', 'Education', 'Business', 'Wellness'],
                      onChanged: (value) {
                        context.read<EventFormBloc>().add(UpdateCategory(value!));
                      },
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Date & Time Section
                _buildSectionTitle('Date & Time'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Date Picker
                    Expanded(
                      child: BlocListener<EventFormBloc, EventFormState>(
                        listener: (context, state) {
                          // Update controller text when state changes (outside build)
                          if (state is EventFormUpdated && state.selectedDate != null) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) {
                                _dateController.text = DateFormat('yyyy-MM-dd').format(state.selectedDate!);
                              }
                            });
                          }
                        },
                        child: _buildTextFormField(
                          controller: _dateController,
                          label: 'Date',
                          hint: 'Select date',
                          readOnly: true,
                          suffixIcon: Icons.calendar_today,
                          onTap: () => _selectDate(context),
                          validator: (value) => value?.isEmpty == true ? 'Date is required' : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Time Picker
                    Expanded(
                      child: BlocListener<EventFormBloc, EventFormState>(
                        listener: (context, state) {
                          // Update controller text when state changes (outside build)
                          if (state is EventFormUpdated && state.selectedTime != null) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) {
                                _timeController.text = state.selectedTime!.format(context);
                              }
                            });
                          }
                        },
                        child: _buildTextFormField(
                          controller: _timeController,
                          label: 'Time',
                          hint: 'Select time',
                          readOnly: true,
                          suffixIcon: Icons.access_time,
                          onTap: () => _selectTime(context),
                          validator: (value) => value?.isEmpty == true ? 'Time is required' : null,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Description Section
                _buildSectionTitle('Description'),
                const SizedBox(height: 12),
                _buildTextFormField(
                  controller: _descriptionController,
                  label: 'Event Description',
                  hint: 'Describe your event in detail...',
                  maxLines: 4,
                  validator: (value) => value?.isEmpty == true ? 'Description is required' : null,
                ),
                const SizedBox(height: 24),

                // Event Settings Section
                _buildSectionTitle('Event Settings'),
                const SizedBox(height: 12),
                
                // Status Dropdown
                BlocBuilder<EventFormBloc, EventFormState>(
                  builder: (context, state) {
                    final currentState = state is EventFormUpdated ? state : null;
                    return _buildDropdownField<String>(
                      value: currentState?.status ?? 'upcoming',
                      label: 'Status',
                      items: const ['upcoming', 'live', 'ended'],
                      onChanged: (value) {
                        context.read<EventFormBloc>().add(UpdateStatus(value!));
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Ticket Type Dropdown
                BlocBuilder<EventFormBloc, EventFormState>(
                  builder: (context, state) {
                    final currentState = state is EventFormUpdated ? state : null;
                    return _buildDropdownField<String>(
                      value: currentState?.ticketType ?? 'NFT',
                      label: 'Ticket Type',
                      items: const ['NFT', 'General', 'VIP'],
                      onChanged: (value) {
                        context.read<EventFormBloc>().add(UpdateTicketType(value!));
                      },
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Price Input Field
                BlocBuilder<EventFormBloc, EventFormState>(
                  builder: (context, state) {
                    // final currentState = state is EventFormUpdated ? state : null;
                    // final currentPrice = currentState?.price ?? 0.0;
                    
                    // // Set controller text if it's different (avoid infinite loop)
                    // if (_priceController.text != currentPrice.toString() && currentPrice > 0) {
                    //   _priceController.text = currentPrice.toString();
                    // } else if (currentPrice == 0.0 && _priceController.text.isNotEmpty) {
                    //   // Keep the controller as is when user is typing
                    // }
                    
                    return _buildTextFormField(
                      controller: _priceController,
                      label: 'Price (Kes)',
                      hint: 'Enter price or leave blank for free',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final price = double.tryParse(value);
                          if (price == null || price < 0) {
                            return 'Please enter a valid price';
                          }
                        }
                        return null;
                      },
                      onChanged: (value) {
                        final price = double.tryParse(value) ?? 0.0;
                        context.read<EventFormBloc>().add(UpdatePrice(price));
                      },
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Image Upload Section
                _buildSectionTitle('Event Thumbnail'),
                const SizedBox(height: 12),
                BlocBuilder<EventFormBloc, EventFormState>(
                  builder: (context, state) {
                    final currentState = state is EventFormUpdated ? state : null;
                    final selectedImage = currentState?.selectedImage;
                    final isUploading = state is EventFormImageUploading;

                    return _buildImageUploadField(
                      selectedImage: selectedImage,
                      isUploading: isUploading,
                      onTap: () {
                        context.read<EventFormBloc>().add(SelectImage());
                      },
                    );
                  },
                ),
                const SizedBox(height: 32),

                // Submit Button
                BlocBuilder<EventFormBloc, EventFormState>(
                  builder: (context, state) {
                    final isLoading = state is EventFormLoading;
                    
                    return SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF000000),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Create Event',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build section title with consistent styling
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  /// Build styled text form field with box decoration
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    bool readOnly = false,
    int maxLines = 1,
    IconData? suffixIcon,
    VoidCallback? onTap,
    TextInputType? keyboardType,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      readOnly: readOnly,
      maxLines: maxLines,
      onTap: onTap,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: Colors.grey[600]) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        labelStyle: TextStyle(color: Colors.grey[700]),
        hintStyle: TextStyle(color: Colors.grey[500]),
      ),
    );
  }

  /// Build styled dropdown field with box decoration
  Widget _buildDropdownField<T>({
    required T value,
    required String label,
    required List<T> items,
    required void Function(T?) onChanged,
  }) {
    return DropdownButtonFormField2<T>(
      value: value,
      items: items.map((item) => DropdownMenuItem(
        value: item,
        child: Center( // Center each item
          child: Text(
            item.toString().replaceAll('-', ' '),
            textAlign: TextAlign.center,
          ),
        ),
      )).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey, width: 1),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        labelStyle: TextStyle(color: Colors.grey[700]),
      ),
      dropdownStyleData: DropdownStyleData(
        maxHeight: 200,
        width: MediaQuery.of(context).size.width * 0.6, // Reduced dropdown width
        offset: const Offset(0, -5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12), // Match field's border radius
        ),
      ),
      menuItemStyleData: const MenuItemStyleData(
        height: 60,
        padding: EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  /// Build image upload field with preview
  Widget _buildImageUploadField({
    File? selectedImage,
    bool isUploading = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: isUploading ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey[300]!,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[50],
        ),
        child: selectedImage != null
            ? Stack(
                children: [
                  // Image preview
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      selectedImage,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Upload overlay when uploading
                  if (isUploading)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Colors.white),
                            SizedBox(height: 8),
                            Text(
                              'Uploading...',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 48,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tap to select event thumbnail',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Recommended: 1200x800px, JPG or PNG',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// Handle date selection
  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.indigo,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      context.read<EventFormBloc>().add(SelectDate(picked));
    }
  }

  /// Handle time selection
  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      context.read<EventFormBloc>().add(SelectTime(picked));
    }
  }

  /// Handle form submission
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Check if date and time are selected
      final currentState = context.read<EventFormBloc>().state;
      if (currentState is EventFormUpdated) {
        if (currentState.selectedDate == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select a date'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        if (currentState.selectedTime == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select a time'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      context.read<EventFormBloc>().add(
        SubmitEventForm(
          title: _titleController.text,
          description: _descriptionController.text,
          location: _locationController.text,
        ),
      );
    }
  }
}