import 'package:logging/logging.dart';
import 'package:my_awesome_app/api/sewclass_api.dart';
import 'package:my_awesome_app/model/sewclass.dart';
import 'package:my_awesome_app/model/photo.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:convert';

class SewclassBloc {
  static SewclassBloc? _instance;

  factory SewclassBloc() {
    _instance ??= SewclassBloc._internal();
    return _instance!;
  }

  SewclassBloc._internal() {
    _log.info('SewclassBloc initialized');
    // Set the logger level to FINE for more detailed logs during development
    Logger.root.level = Level.FINE;
  }

  final _log = Logger('SewclassBloc');

  // Individual property streams
  final PublishSubject<String> _nameSubject = PublishSubject<String>();
  Stream<String> get nameStream => _nameSubject.stream;

  final PublishSubject<String> _descriptionSubject = PublishSubject<String>();
  Stream<String> get descriptionStream => _descriptionSubject.stream;

  final PublishSubject<int> _maxPeopleSubject = PublishSubject<int>();
  Stream<int> get maxPeopleStream => _maxPeopleSubject.stream;

  final PublishSubject<double> _pricePerPersonSubject = PublishSubject<double>();
  Stream<double> get pricePerPersonStream => _pricePerPersonSubject.stream;

  final PublishSubject<int> _durationSubject = PublishSubject<int>();
  Stream<int> get durationStream => _durationSubject.stream;

  final PublishSubject<List<Photo>> _photosSubject = PublishSubject<List<Photo>>();
  Stream<List<Photo>> get photosStream => _photosSubject.stream;

  // Complete Sewclass object streams
  final PublishSubject<Sewclass> _sewclassSubject = PublishSubject<Sewclass>();
  Stream<Sewclass> get sewclassStream => _sewclassSubject.stream;

  final PublishSubject<List<Sewclass>> _sewclassesSubject = PublishSubject<List<Sewclass>>();
  Stream<List<Sewclass>> get sewclassesStream => _sewclassesSubject.stream;

  // Methods to update individual properties
  void setName(String name) {
    _log.info('setName: $name');
    _nameSubject.add(name);
  }

  void setDescription(String description) {
    _log.info('setDescription: $description');
    _descriptionSubject.add(description);
  }

  void setMaxPeople(int maxPeople) {
    _log.info('setMaxPeople: $maxPeople');
    _maxPeopleSubject.add(maxPeople);
  }

  void setPricePerPerson(double pricePerPerson) {
    _log.info('setPricePerPerson: $pricePerPerson');
    _pricePerPersonSubject.add(pricePerPerson);
  }

  void setDuration(int duration) {
    _log.info('setDuration: $duration');
    _durationSubject.add(duration);
  }

  void setPhotos(List<Photo> photos) {
    _log.info('setPhotos: ${photos.length} photos');
    _photosSubject.add(photos);
  }

  // API interaction methods
  Future<void> fetchSewclasses() async {
    _log.info('fetchSewclasses() - Starting API request');
    try {
      final api = SewClassApi();
      _log.fine('Sending request to fetch sew classes');
      final response = await api.getSewClasses();
      
      if (response.data != null) {
        _log.info('Successfully fetched ${response.data!.length} sew classes');
        
        // Log some details about the data for debugging
        for (final sewclass in response.data!) {
          _log.fine('Fetched class: ${sewclass.id} - ${sewclass.name} with ${sewclass.photos.length} photos');
        }
        
        _sewclassesSubject.add(response.data!);
      } else if (response.error != null) {
        _log.warning('Error fetching sew classes: ${response.error}');
        _sewclassesSubject.addError(response.error!);
      } else {
        _log.warning('Received empty response with no error');
        _sewclassesSubject.addError(Exception('No data received from server'));
      }
    } on FormatException catch (e) {
      _log.severe('JSON parsing error when fetching sew classes', e);
      _sewclassesSubject.addError(Exception('Failed to parse API response: ${e.message}'));
    } catch (e, stackTrace) {
      _log.severe('Exception fetching sew classes', e);
      _log.severe('Stack trace: $stackTrace');
      _sewclassesSubject.addError(e);
    }
  }

  Future<void> fetchSewclassById(String id) async {
    _log.info('fetchSewclassById($id) - Starting API request');
    try {
      final api = SewClassApi();
      _log.fine('Sending request to fetch sew class with ID: $id');
      final response = await api.getSewClassById(id);
      
      if (response.data != null) {
        final sewclass = response.data!;
        _log.info('Successfully fetched sew class: ${sewclass.name} (ID: ${sewclass.id})');
        _log.fine('Sew class details: ${sewclass.toString()}');
        
        // Debug the number of photos received
        _log.fine('Number of photos received: ${sewclass.photos.length}');
        for (int i = 0; i < sewclass.photos.length; i++) {
          _log.fine('Photo $i: ID=${sewclass.photos[i].id}, mainPhoto=${sewclass.photos[i].mainPhoto}');
        }
        
        _sewclassSubject.add(sewclass);
        
        // Also update individual property streams
        _log.fine('Updating individual property streams with fetched data');
        _nameSubject.add(sewclass.name);
        _descriptionSubject.add(sewclass.description);
        _maxPeopleSubject.add(sewclass.maxPeople);
        _pricePerPersonSubject.add(sewclass.pricePerPerson);
        _durationSubject.add(sewclass.duration);
        _photosSubject.add(sewclass.photos);
      } else if (response.error != null) {
        _log.warning('Error fetching sew class: ${response.error}');
        _sewclassSubject.addError(response.error!);
      } else {
        _log.warning('Received empty response with no error for ID: $id');
        _sewclassSubject.addError(Exception('No data received for sew class with ID: $id'));
      }
    } on FormatException catch (e) {
      _log.severe('JSON parsing error when fetching sew class with ID: $id', e);
      _sewclassSubject.addError(Exception('Failed to parse API response: ${e.message}'));
    } catch (e, stackTrace) {
      _log.severe('Failed to fetch sew class with ID: $id', e);
      _log.severe('Stack trace: $stackTrace');
      _sewclassSubject.addError(e);
    }
  }

  Future<void> createSewclass(Map<String, dynamic> sewclassData) async {
    _log.info('createSewclass - Starting API request');
    try {
      // Log the data being sent
      _log.fine('Sending sew class data: ${sewclassData.toString()}');
      
      final api = SewClassApi();
      final response = await api.createSewClass(sewclassData);
      
      if (response.error != null) {
        _log.warning('Error creating sew class: ${response.error}');
        _sewclassesSubject.addError(response.error!);
        return;
      }
      
      _log.info('Sew class created successfully');
      
      // Refresh the list after creating
      _log.fine('Refreshing sew classes list after creation');
      await fetchSewclasses();
    } on FormatException catch (e) {
      _log.severe('JSON parsing error when creating sew class', e);
      _sewclassesSubject.addError(Exception('Failed to parse API response: ${e.message}'));
    } catch (e, stackTrace) {
      _log.severe('Failed to create sew class', e);
      _log.severe('Stack trace: $stackTrace');
      _sewclassesSubject.addError(e);
    }
  }

  Future<void> updateSewclass(String id, Map<String, dynamic> sewclassData) async {
    _log.info('updateSewclass($id) - Starting API request');
    try {
      // Log the data being sent
      _log.fine('Updating sew class with ID: $id');
      _log.fine('Update data: ${sewclassData.toString()}');
      
      final api = SewClassApi();
      final response = await api.updateSewClass(id, sewclassData);
      
      if (response.error != null) {
        _log.warning('Error updating sew class: ${response.error}');
        _sewclassSubject.addError(response.error!);
        return;
      }
      
      _log.info('Sew class updated successfully');
      
      // Refresh the list and the specific class after updating
      _log.fine('Refreshing sew classes list after update');
      await fetchSewclasses();
      
      _log.fine('Refreshing the updated sew class details');
      await fetchSewclassById(id);
    } on FormatException catch (e) {
      _log.severe('JSON parsing error when updating sew class with ID: $id', e);
      _sewclassSubject.addError(Exception('Failed to parse API response: ${e.message}'));
    } catch (e, stackTrace) {
      _log.severe('Failed to update sew class with ID: $id', e);
      _log.severe('Stack trace: $stackTrace');
      _sewclassSubject.addError(e);
    }
  }

  Future<void> deleteSewclass(String id) async {
    _log.info('deleteSewclass($id) - Starting API request');
    try {
      _log.fine('Sending request to delete sew class with ID: $id');
      
      final api = SewClassApi();
      final response = await api.deleteSewClass(id);
      
      if (response.error != null) {
        _log.warning('Error deleting sew class: ${response.error}');
        _sewclassesSubject.addError(response.error!);
        return;
      }
      
      _log.info('Sew class deleted successfully');
      
      // Refresh the list after deleting
      _log.fine('Refreshing sew classes list after deletion');
      await fetchSewclasses();
    } on FormatException catch (e) {
      _log.severe('JSON parsing error when deleting sew class with ID: $id', e);
      _sewclassesSubject.addError(Exception('Failed to parse API response: ${e.message}'));
    } catch (e, stackTrace) {
      _log.severe('Failed to delete sew class with ID: $id', e);
      _log.severe('Stack trace: $stackTrace');
      _sewclassesSubject.addError(e);
    }
  }

  void dispose() {
    _nameSubject.close();
    _descriptionSubject.close();
    _maxPeopleSubject.close();
    _pricePerPersonSubject.close();
    _durationSubject.close();
    _photosSubject.close();
    _sewclassSubject.close();
    _sewclassesSubject.close();
    _log.info('SewclassBloc disposed');
  }
}
