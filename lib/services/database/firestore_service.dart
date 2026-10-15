// lib/services/database/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/enums/payment_status.dart';
import '../../models/payment_method_model.dart';
import '../../models/branch_model.dart';
import '../../models/consent_form_model.dart';
import '../../models/artist_model.dart';
import '../../models/customer_model.dart';
import '../../models/settings_model.dart';
import '../../models/studio_model.dart';
import '../../models/user_model.dart';
import '../../models/service_model.dart';
import '../../models/appointment_model.dart';
import '../../models/payment_model.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============================================================
  // USERS
  // ============================================================

  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).update(user.toJson());
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  Future<UserModel?> getUser(String id) async {
    try {
      final doc = await _firestore.collection('users').doc(id).get();
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return UserModel.fromJson(data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return UserModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get users: $e');
    }
  }

  Future<List<UserModel>> getUsersByRole(String role) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: role)
          .orderBy('name')
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return UserModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get users by role: $e');
    }
  }

  Future<String> saveUser(UserModel user) async {
    try {
      final docRef = await _firestore.collection('users').add(user.toJson());
      await docRef.update({'id': docRef.id});
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to save user: $e');
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      await _firestore.collection('users').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  Future<UserModel?> getUserByEmail(String email) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        data['id'] = snapshot.docs.first.id;
        return UserModel.fromJson(data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user by email: $e');
    }
  }

  // ============================================================
  // CONSENT FORMS
  // ============================================================

  Stream<List<ConsentFormModel>> streamConsentForms() {
    return _firestore
        .collection('consent_forms')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return ConsentFormModel.fromJson(data);
      }).toList();
    });
  }

  Future<List<ConsentFormModel>> getConsentForms() async {
    final snapshot = await _firestore
        .collection('consent_forms')
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return ConsentFormModel.fromJson(data);
    }).toList();
  }

  Future<String> saveConsentForm(ConsentFormModel form) async {
    try {
      final docRef = await _firestore.collection('consent_forms').add(form.toJson());
      await docRef.update({'id': docRef.id});
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to save consent form: $e');
    }
  }

  Future<void> updateConsentForm(ConsentFormModel form) async {
    try {
      await _firestore.collection('consent_forms').doc(form.id).update(form.toJson());
    } catch (e) {
      throw Exception('Failed to update consent form: $e');
    }
  }

  Future<void> deleteConsentForm(String id) async {
    try {
      await _firestore.collection('consent_forms').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete consent form: $e');
    }
  }

  Future<ConsentFormModel?> getConsentForm(String id) async {
    try {
      final doc = await _firestore.collection('consent_forms').doc(id).get();
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return ConsentFormModel.fromJson(data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get consent form: $e');
    }
  }

  Future<List<ConsentFormModel>> getConsentFormsByArtist(String artistId) async {
    final snapshot = await _firestore
        .collection('consent_forms')
        .where('artistId', isEqualTo: artistId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return ConsentFormModel.fromJson(data);
    }).toList();
  }

  Future<List<ConsentFormModel>> getConsentFormsByCustomer(String customerId) async {
    final snapshot = await _firestore
        .collection('consent_forms')
        .where('customer.id', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return ConsentFormModel.fromJson(data);
    }).toList();
  }

  Future<List<ConsentFormModel>> getConsentFormsByBranch(String branchId) async {
    final snapshot = await _firestore
        .collection('consent_forms')
        .where('appointment.branchId', isEqualTo: branchId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return ConsentFormModel.fromJson(data);
    }).toList();
  }

  Future<List<ConsentFormModel>> getConsentFormsByDateRange(
      DateTime startDate,
      DateTime endDate,
      ) async {
    final snapshot = await _firestore
        .collection('consent_forms')
        .where('createdAt', isGreaterThanOrEqualTo: startDate.toIso8601String())
        .where('createdAt', isLessThanOrEqualTo: endDate.toIso8601String())
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return ConsentFormModel.fromJson(data);
    }).toList();
  }

  // ============================================================
  // ARTISTS
  // ============================================================

  Future<List<ArtistModel>> getArtists() async {
    final snapshot = await _firestore
        .collection('artists')
        .orderBy('name')
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return ArtistModel.fromJson(data);
    }).toList();
  }

  Future<List<ArtistModel>> getActiveArtists() async {
    final snapshot = await _firestore
        .collection('artists')
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return ArtistModel.fromJson(data);
    }).toList();
  }

  Future<List<ArtistModel>> getArtistsByBranch(String branchId) async {
    final snapshot = await _firestore
        .collection('artists')
        .where('branchId', isEqualTo: branchId)
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return ArtistModel.fromJson(data);
    }).toList();
  }

  Future<String> saveArtist(ArtistModel artist) async {
    try {
      final docRef = await _firestore.collection('artists').add(artist.toJson());
      await docRef.update({'id': docRef.id});
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to save artist: $e');
    }
  }

  Future<void> updateArtist(ArtistModel artist) async {
    try {
      await _firestore.collection('artists').doc(artist.id).update(artist.toJson());
    } catch (e) {
      throw Exception('Failed to update artist: $e');
    }
  }

  Future<void> deleteArtist(String id) async {
    try {
      await _firestore.collection('artists').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete artist: $e');
    }
  }

  Future<ArtistModel?> getArtist(String id) async {
    try {
      final doc = await _firestore.collection('artists').doc(id).get();
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return ArtistModel.fromJson(data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get artist: $e');
    }
  }

  // ============================================================
  // CUSTOMERS
  // ============================================================

  Future<List<CustomerModel>> getCustomers() async {
    final snapshot = await _firestore
        .collection('customers')
        .orderBy('name')
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return CustomerModel.fromJson(data);
    }).toList();
  }

  Future<String> saveCustomer(CustomerModel customer) async {
    try {
      final docRef = await _firestore.collection('customers').add(customer.toJson());
      await docRef.update({'id': docRef.id});
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to save customer: $e');
    }
  }

  Future<void> updateCustomer(CustomerModel customer) async {
    try {
      await _firestore.collection('customers').doc(customer.id).update(customer.toJson());
    } catch (e) {
      throw Exception('Failed to update customer: $e');
    }
  }

  Future<void> deleteCustomer(String id) async {
    try {
      await _firestore.collection('customers').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete customer: $e');
    }
  }

  Future<CustomerModel?> getCustomerByPhone(String phone) async {
    try {
      final snapshot = await _firestore
          .collection('customers')
          .where('mobile', isEqualTo: phone)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        data['id'] = snapshot.docs.first.id;
        return CustomerModel.fromJson(data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get customer: $e');
    }
  }

  Future<CustomerModel?> getCustomerByEmail(String email) async {
    try {
      final snapshot = await _firestore
          .collection('customers')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        data['id'] = snapshot.docs.first.id;
        return CustomerModel.fromJson(data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get customer: $e');
    }
  }

  // ============================================================
  // SERVICES
  // ============================================================

  Future<List<ServiceModel>> getServices() async {
    final snapshot = await _firestore
        .collection('services')
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return ServiceModel.fromJson(data);
    }).toList();
  }

  Future<List<ServiceModel>> getAllServices() async {
    final snapshot = await _firestore
        .collection('services')
        .orderBy('name')
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return ServiceModel.fromJson(data);
    }).toList();
  }

  Future<String> saveService(ServiceModel service) async {
    try {
      final docRef = await _firestore.collection('services').add(service.toJson());
      await docRef.update({'id': docRef.id});
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to save service: $e');
    }
  }

  Future<void> updateService(ServiceModel service) async {
    try {
      await _firestore.collection('services').doc(service.id).update(service.toJson());
    } catch (e) {
      throw Exception('Failed to update service: $e');
    }
  }

  Future<void> deleteService(String id) async {
    try {
      await _firestore.collection('services').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete service: $e');
    }
  }

  // ============================================================
  // PAYMENT METHODS
  // ============================================================

  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    final snapshot = await _firestore
        .collection('payment_methods')
        .where('isActive', isEqualTo: true)
        .orderBy('displayOrder')
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return PaymentMethodModel.fromJson(data);
    }).toList();
  }

  Future<List<PaymentMethodModel>> getAllPaymentMethods() async {
    final snapshot = await _firestore
        .collection('payment_methods')
        .orderBy('displayOrder')
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return PaymentMethodModel.fromJson(data);
    }).toList();
  }

  Future<String> savePaymentMethod(PaymentMethodModel method) async {
    try {
      final docRef = await _firestore.collection('payment_methods').add(method.toJson());
      await docRef.update({'id': docRef.id});
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to save payment method: $e');
    }
  }

  Future<void> updatePaymentMethod(PaymentMethodModel method) async {
    try {
      await _firestore.collection('payment_methods').doc(method.id).update(method.toJson());
    } catch (e) {
      throw Exception('Failed to update payment method: $e');
    }
  }

  Future<void> deletePaymentMethod(String id) async {
    try {
      await _firestore.collection('payment_methods').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete payment method: $e');
    }
  }

  // ============================================================
  // STUDIO
  // ============================================================

  Future<String> saveStudio(StudioModel studio) async {
    try {
      final docRef = await _firestore.collection('studios').add(studio.toJson());
      await docRef.update({'id': docRef.id});
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to save studio: $e');
    }
  }

  Future<StudioModel?> getStudio() async {
    try {
      final snapshot = await _firestore.collection('studios').limit(1).get();
      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        data['id'] = snapshot.docs.first.id;
        return StudioModel.fromJson(data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get studio: $e');
    }
  }

  Future<void> updateStudio(StudioModel studio) async {
    try {
      await _firestore.collection('studios').doc(studio.id).update(studio.toJson());
    } catch (e) {
      throw Exception('Failed to update studio: $e');
    }
  }

  Future<void> deleteStudio(String id) async {
    try {
      await _firestore.collection('studios').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete studio: $e');
    }
  }

  // ============================================================
  // BRANCHES
  // ============================================================

  Future<List<BranchModel>> getBranches() async {
    try {
      final snapshot = await _firestore
          .collection('branches')
          .where('isActive', isEqualTo: true)
          //.orderBy('name')
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return BranchModel.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error getting branches: $e');
      return [];
    }
  }

  Future<List<BranchModel>> getAllBranches() async {
    try {
      final snapshot = await _firestore.collection('branches').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return BranchModel.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error getting all branches: $e');
      return [];
    }
  }

  Future<String> saveBranch(BranchModel branch) async {
    try {
      final docRef = await _firestore.collection('branches').add(branch.toJson());
      await docRef.update({'id': docRef.id});
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to save branch: $e');
    }
  }

  Future<void> updateBranch(BranchModel branch) async {
    try {
      await _firestore.collection('branches').doc(branch.id).update(branch.toJson());
    } catch (e) {
      throw Exception('Failed to update branch: $e');
    }
  }

  Future<void> deleteBranch(String id) async {
    try {
      await _firestore.collection('branches').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete branch: $e');
    }
  }

  Future<BranchModel?> getBranchById(String id) async {
    try {
      final doc = await _firestore.collection('branches').doc(id).get();
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return BranchModel.fromJson(data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get branch: $e');
    }
  }

  // ============================================================
  // APPOINTMENTS
  // ============================================================

  Future<List<AppointmentModel>> getAppointments() async {
    final snapshot = await _firestore
        .collection('appointments')
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return AppointmentModel.fromJson(data);
    }).toList();
  }

  Future<List<AppointmentModel>> getAppointmentsByCustomer(String customerId) async {
    final snapshot = await _firestore
        .collection('appointments')
        .where('customerId', isEqualTo: customerId)
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return AppointmentModel.fromJson(data);
    }).toList();
  }

  Future<List<AppointmentModel>> getAppointmentsByArtist(String artistId) async {
    final snapshot = await _firestore
        .collection('appointments')
        .where('artistId', isEqualTo: artistId)
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return AppointmentModel.fromJson(data);
    }).toList();
  }

  Future<List<AppointmentModel>> getAppointmentsByBranch(String branchId) async {
    final snapshot = await _firestore
        .collection('appointments')
        .where('branchId', isEqualTo: branchId)
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return AppointmentModel.fromJson(data);
    }).toList();
  }

  Future<List<AppointmentModel>> getAppointmentsByDate(DateTime date) async {
    final startDate = DateTime(date.year, date.month, date.day);
    final endDate = startDate.add(const Duration(days: 1));
    final snapshot = await _firestore
        .collection('appointments')
        .where('date', isGreaterThanOrEqualTo: startDate.toIso8601String())
        .where('date', isLessThan: endDate.toIso8601String())
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return AppointmentModel.fromJson(data);
    }).toList();
  }

  Future<String> saveAppointment(AppointmentModel appointment) async {
    try {
      final docRef = await _firestore.collection('appointments').add(appointment.toJson());
      await docRef.update({'id': docRef.id});
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to save appointment: $e');
    }
  }

  Future<void> updateAppointment(AppointmentModel appointment) async {
    try {
      await _firestore.collection('appointments').doc(appointment.id).update(appointment.toJson());
    } catch (e) {
      throw Exception('Failed to update appointment: $e');
    }
  }

  Future<void> deleteAppointment(String id) async {
    try {
      await _firestore.collection('appointments').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete appointment: $e');
    }
  }

  // ============================================================
  // PAYMENTS
  // ============================================================

  Future<List<PaymentModel>> getPayments() async {
    final snapshot = await _firestore
        .collection('payments')
        .orderBy('paymentDate', descending: true)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return PaymentModel.fromJson(data);
    }).toList();
  }

  Future<List<PaymentModel>> getPaymentsByConsentForm(String consentFormId) async {
    final snapshot = await _firestore
        .collection('payments')
        .where('consentFormId', isEqualTo: consentFormId)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return PaymentModel.fromJson(data);
    }).toList();
  }

  Future<String> savePayment(PaymentModel payment) async {
    try {
      final docRef = await _firestore.collection('payments').add(payment.toJson());
      await docRef.update({'id': docRef.id});
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to save payment: $e');
    }
  }

  Future<void> updatePayment(PaymentModel payment) async {
    try {
      await _firestore.collection('payments').doc(payment.id).update(payment.toJson());
    } catch (e) {
      throw Exception('Failed to update payment: $e');
    }
  }

  Future<void> deletePayment(String id) async {
    try {
      await _firestore.collection('payments').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete payment: $e');
    }
  }

  // ============================================================
  // SETTINGS
  // ============================================================

  Future<SettingsModel?> getSettings() async {
    try {
      final snapshot = await _firestore.collection('settings').limit(1).get();
      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        data['id'] = snapshot.docs.first.id;
        return SettingsModel.fromJson(data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get settings: $e');
    }
  }

  Future<void> saveSettings(SettingsModel settings) async {
    try {
      await _firestore.collection('settings').doc(settings.id).set(settings.toJson());
    } catch (e) {
      throw Exception('Failed to save settings: $e');
    }
  }

  Future<void> updateSettings(SettingsModel settings) async {
    try {
      await _firestore.collection('settings').doc(settings.id).update(settings.toJson());
    } catch (e) {
      throw Exception('Failed to update settings: $e');
    }
  }

  // ============================================================
  // DASHBOARD STATS
  // ============================================================

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final customers = await getCustomers();
      final appointments = await getAppointments();
      final consentForms = await getConsentForms();

      final totalRevenue = consentForms.fold(
        0.0,
            (sum, form) => sum + form.payment.finalAmount,
      );

      final today = DateTime.now();
      final todayAppointments = appointments.where((a) =>
      a.date.year == today.year &&
          a.date.month == today.month &&
          a.date.day == today.day).toList();

      return {
        'totalCustomers': customers.length,
        'totalRevenue': totalRevenue,
        'todayAppointments': todayAppointments.length,
        'totalAppointments': appointments.length,
        'pendingPayments': consentForms.where((f) =>
        f.payment.status == PaymentStatus.pending).length,
        'completedPayments': consentForms.where((f) =>
        f.payment.status == PaymentStatus.paid).length,
      };
    } catch (e) {
      throw Exception('Failed to get dashboard stats: $e');
    }
  }

  // ============================================================
  // REAL-TIME LISTENERS
  // ============================================================

  Stream<List<ConsentFormModel>> listenConsentForms() {
    return _firestore
        .collection('consent_forms')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return ConsentFormModel.fromJson(data);
      }).toList();
    });
  }

  Stream<List<AppointmentModel>> listenAppointments() {
    return _firestore
        .collection('appointments')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return AppointmentModel.fromJson(data);
      }).toList();
    });
  }

  Stream<List<AppointmentModel>> listenAppointmentsByDate(DateTime date) {
    final startDate = DateTime(date.year, date.month, date.day);
    final endDate = startDate.add(const Duration(days: 1));
    return _firestore
        .collection('appointments')
        .where('date', isGreaterThanOrEqualTo: startDate.toIso8601String())
        .where('date', isLessThan: endDate.toIso8601String())
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return AppointmentModel.fromJson(data);
      }).toList();
    });
  }

  // ============================================================
  // SEARCH
  // ============================================================

  Future<List<ConsentFormModel>> searchConsentForms(String query) async {
    try {
      final snapshot = await _firestore
          .collection('consent_forms')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return ConsentFormModel.fromJson(data);
      })
          .where((form) =>
      form.customer.name.toLowerCase().contains(query.toLowerCase()) ||
          form.customer.mobile.contains(query) ||
          form.id.toLowerCase().contains(query.toLowerCase()) ||
          form.artistName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      throw Exception('Failed to search consent forms: $e');
    }
  }
}