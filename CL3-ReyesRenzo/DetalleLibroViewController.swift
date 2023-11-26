//
//  DetalleLibroViewController.swift
//  CL3-ReyesRenzo
//
//  Created by DAMII on 20/11/23.
//

import UIKit

class DetalleLibroViewController: UIViewController {

    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var lblSubtitle: UILabel!
    
    @IBOutlet weak var lblIsbn: UILabel!
    
    @IBOutlet weak var lblPrice: UILabel!
    
    @IBOutlet weak var lblUrl: UILabel!
    
    @IBOutlet weak var imgLibro: UIImageView!
    
    var bean:Libro?
    var api:ApiResponse!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Verificar si bean tiene un valor antes de acceder a sus propiedades
               if let bean = bean {
                   lblTitle.text = bean.title
                   lblSubtitle.text = bean.subtitle
                   lblIsbn.text = "ISBN: " + bean.isbn13
                   lblPrice.text = "Price: " + bean.price
                   lblUrl.text = bean.url

                   if let url = URL(string: bean.image) {
                       imgLibro.kf.setImage(with: url)
                   } else {
                       // Manejar el caso en el que la URL de la imagen es inválida
                       print("URL de imagen inválida")
                   }
               } else {
                   // Manejar el caso en el que bean es nil
                   print("Bean es nil")
               }
           }
    }

