//
//  ContentView.swift
//  Curso-ios-ApiRest
//
//  Created by Equipo 9 on 11/2/26.
//

import SwiftUI

// struct para rpeparar la consulta al API REST

struct Post: Codable, Identifiable {
    var id: Int
    var title: String
    var body: String
    // podremos omitir los campos que no necesitemos, como userID
}

struct ContentView: View {

    @State private var posts: [Post] = []

    var body: some View {
        VStack {
            List(posts) { post in
                HStack {
                    Text("\(post.id)")
                    Text(post.title)
                }
                
            }
            Button("Refreca los datos") {
                Task {
                    try await crearPost()
                }
            }
            .padding(10)
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .task {
            do {
                try await posts = obtenerPost()
            } catch {
                print(error)
            }
        }
    }

    
    // conosulta de post
    func obtenerPost() async throws -> [Post] {
        // Nota .- en decodificar
        // Si en ñla aPI tenemos de un formato a otro
        // por ejemplo de snakeCase a SnakeCase y viceversa
        // Si enla api tenemos nobre_usuario
        // en nuestro sistema denemos nombreUsuario
//        
//         let decoder = JSONDecoder()
//         decoder.keyDecodingStrategy = .convertFromSnakeCase
//
        

        // preparamos la url url
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts")
        else {
            throw URLError(.badURL)
        }

        // en una tupoa los datos y por otra parte el reponse lo que nos da el servidor
        let (data, response) = try await URLSession.shared.data(from: url)

        // leemos los post
        guard let httpResponse = response as? HTTPURLResponse,
            httpResponse.statusCode == 200
                
        else {
            let respuestaError = response as? HTTPURLResponse
            print(respuestaError?.statusCode)
            
            throw URLError(.badServerResponse)
        }

        let posts = try JSONDecoder().decode([Post].self, from: data) 

        
        return posts

    }
    
    // Usaremos el "post" de http para crear uns publicación (post)
    // al no tener al API KEY no podemos grabarlos solo lo creamos y losenviamos a modo
    // de ejemplo y rpuebas de repsuesta del servisor
    func crearPost() async throws {
        
        // preparamos la url url
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts")
        else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        
        // indicaremos que enviamos un JSON
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // creamos un post "harcodeado"
        
        let nuevoPost = Post(id: 0, title: "Es de día ? consulta tu app de moda", body: "Consulta tu APP de SwiftUI")
        
        let datosAEnviar = try JSONEncoder().encode(nuevoPost)
        
        request.httpBody = datosAEnviar
        
        // enviamos los datos
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 201
                
        else {
            throw URLError(.badServerResponse)
        }
        print("\(httpResponse.statusCode)")
        print("Post creado correctamente")
    }
}

#Preview {
    ContentView()
}
