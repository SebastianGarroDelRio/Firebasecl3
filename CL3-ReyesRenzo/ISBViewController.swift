//
//  ISBViewController.swift
//  CL3-ReyesRenzo
//
//  Created by DAMII on 21/11/23.
//

import UIKit
import Alamofire
import FirebaseFirestore
import Toaster
struct BookResponse: Codable {
    var error: String?
        var title: String?
        var subtitle: String?
        var authors: String?
        var publisher: String?
        var language: String?
        var isbn10: String?
        var isbn13: String?
        var pages: String?
        var year: String?
        var rating: String?
        var desc: String?
        var price: String?
        var image: String?
        var url: String?
}

class ISBViewController: UIViewController {
    
    @IBOutlet weak var imgBook: UIImageView!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblYear: UILabel!
    @IBOutlet weak var lblPages: UILabel!
    @IBOutlet weak var lblLenguaje: UILabel!
    @IBOutlet weak var lblAutor: UILabel!
    @IBOutlet weak var lblSubtitle: UILabel!
    @IBOutlet weak var lblTtitle: UILabel!
    @IBOutlet weak var txtConsultaIsbn: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    
    @IBAction func btnBuscar(_ sender: UIButton) {
            guard let isbn13 = txtConsultaIsbn.text, !isbn13.isEmpty else {
                // Mostrar mensaje de error si el campo ISBN13 está vacío
                Toast(text: "Por favor, ingrese un ISBN13").show()
                return
            }

            consultarLibro(isbn13: isbn13)
        
        }

    func consultarLibro(isbn13: String) {
        let apiUrl = "https://api.itbook.store/1.0/books/\(isbn13)"
        print("API URL:", apiUrl)
        
        AF.request(apiUrl)
            .responseDecodable(of: BookResponse.self) { response in
                switch response.result {
                case .success(let book):
                    print("API Response:", book)

                    DispatchQueue.main.async {
                        self.mostrarDatosLibro(book: book)
                    }
                    
                    if let error = book.error {
                        // Mostrar mensaje de error si la API devuelve un error
                        DispatchQueue.main.async {
                            Toast(text: error).show()
                        }
                        // Restablecer los labels a "NULO"
                        DispatchQueue.main.async {
                            self.mostrarDatosNulos()
                        }
                    } else {
                        // Registrar el libro en Firebase si no está registrado
                        DispatchQueue.main.async {
                            self.registrarEnFirebase(book: book)
                        }
                    }
                    
                case .failure(let error):
                    print("API Error:", error)
                    // Mostrar mensaje de error genérico
                    DispatchQueue.main.async {
                        Toast(text: "Error al consultar el libro").show()
                    }
                    // Restablecer los labels a "NULO"
                    DispatchQueue.main.async {
                        self.mostrarDatosNulos()
                    }
                }
            }
    }

        func mostrarDatosNulos() {
            lblTtitle.text = "NULO"
            lblSubtitle.text = "NULO"
            lblAutor.text = "NULO"
            lblLenguaje.text = "NULO"
            lblPages.text = "NULO"
            lblYear.text = "NULO"
            lblPrice.text = "NULO"
            imgBook.image = nil
        }

    func mostrarDatosLibro(book: BookResponse) {
        DispatchQueue.main.async {
            self.lblTtitle.text = book.title
            self.lblSubtitle.text = book.subtitle
            self.lblAutor.text = book.authors
            self.lblLenguaje.text = book.language
            self.lblPages.text = book.pages
            self.lblYear.text = book.year
            self.lblPrice.text = book.price

            if let imageUrl = book.image, let url = URL(string: imageUrl) {
                self.imgBook.kf.setImage(with: url)
            } else {
                // Puedes configurar una imagen de reemplazo si la URL de la imagen no está disponible
                self.imgBook.image = UIImage(named: "placeholder")
            }
        }
    }

    func registrarEnFirebase(book: BookResponse) {
        let booksCollection = Firestore.firestore().collection("books")

        print("ISBN13 a verificar:", book.isbn13 ?? "N/A")

        // Verificar si el libro ya está registrado en Firebase
        booksCollection.whereField("isbn13", isEqualTo: book.isbn13 ?? "").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error al verificar la existencia del libro en Firebase: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else { return }

            if documents.isEmpty {
                // El libro no está registrado, así que lo registramos
                self.registrarLibroNuevoEnFirebase(book: book, collection: booksCollection)
            } else {
                // El libro ya está registrado
                DispatchQueue.main.async {
                    Toast(text: "El libro ya está registrado en Firebase").show()
                }
            }
        }
    }

    func registrarLibroNuevoEnFirebase(book: BookResponse, collection: CollectionReference) {
        var libro = book
        libro.error = nil // Eliminamos el campo "error" antes de registrar en Firebase

        let libroData: [String: Any] = [
            "title": libro.title ?? "",
            "subtitle": libro.subtitle ?? "",
            "authors": libro.authors ?? "",
            "language": libro.language ?? "",
            "isbn10": libro.isbn10 ?? "",
            "isbn13": libro.isbn13 ?? "",
            "pages": libro.pages ?? "",
            "year": libro.year ?? "",
            "rating": libro.rating ?? "",
            "desc": libro.desc ?? "",
            "price": libro.price ?? "",
            "image": libro.image ?? "",
            "url": libro.url ?? ""
        ]

        collection.addDocument(data: libroData) { error in
            if let error = error {
                print("Error al agregar el libro a Firebase: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    Toast(text: "Error al registrar el libro en Firebase").show()
                }
                return
            }

            // Mostrar mensaje de éxito
            DispatchQueue.main.async {
                Toast(text: "Libro registrado exitosamente en Firebase").show()
            }
        }
    }

    }
