
class Estudiante {
	const property nombre
	var property creditos = 0
	var property carreras = []
	var property materiasAprobadas = []
	
	// TODO Poner esto en un atributo lo deja inconsistente si se inscribe luego en una nueva carrera, mejor un método.
	var todaMateriaEnCarrerasInscripto = carreras.map({carr => carr.materias()}).flatten()

	method promedio() {
		if (not materiasAprobadas.isEmpty()) {
			return materiasAprobadas.map({mate => mate.nota()}).sum() / materiasAprobadas.size()
		}
		else {
			return 0
		}
	}
	method aprobarMateria(materia, nota){
		if (not materiasAprobadas.contains(materia))
		materiasAprobadas.add(new MateriaAprobada(alumno=nombre, materia=materia, nota=nota))
		creditos += materia.creditoQueOtorga()
	}
	method materiasInscribibles(carrera){
		if (carreras.contains(carrera)){
			// TODO asSet innecesario
			// TODO ¿por qué pasa nombre por parámetro?
			return carrera.materias().asSet().filter {mat => mat.puedeInscribirse(nombre)}
		}
		else {
			return "No está inscripto en la carrera" // TODO Mal - Debería tirar excepción. No se puede retornar un mensaje de error.
		}
	}
	method materiasEnQueEstaInscripto(){
		return todaMateriaEnCarrerasInscripto.filter({mate => mate.alumnosInscriptos().contains(self)})
	}
	method materiasEnListaDeEspera(){
		return todaMateriaEnCarrerasInscripto.filter({mate => mate.listaDeEspera().contains(self)})
	}
}

class Materia {
	var property carrera
	const property anio
	const property creditoQueOtorga
	var property alumnosInscriptos = []
	var cupo
	var property listaDeEspera = []
	method puedeInscribirse(estudiante){
		return estudiante.carreras().contains(carrera) and
				
		// TODO Falta subtarea y delegar en estudiante.
		not estudiante.materiasAprobadas().map {apro => apro.materia()}.contains(self) and
		not alumnosInscriptos.contains(estudiante)
	}
	method inscribir(estudiante) {
		if(self.puedeInscribirse(estudiante) and 
			alumnosInscriptos.size() < cupo
		) {
			alumnosInscriptos.add(estudiante)
			return "Inscripto" // TODO No devuelvas el resultado como un string!
		}
		
		// TODO Valida la condición dos veces.
		else if (self.puedeInscribirse(estudiante)) {
			listaDeEspera.add(estudiante)
			return "Agregado a lista de espera"
		}
		else {
			return "El estudiante no puede inscribirse"
		}
	}
	method darDeBaja(estudiante) {
		if (alumnosInscriptos.contains(estudiante)) {
			alumnosInscriptos.remove(estudiante)
		}
		if (not listaDeEspera.isEmpty()) { // TODO OJo, esto tiene que estar dentro del otro if.
			alumnosInscriptos.add(listaDeEspera.first())
			listaDeEspera.remove(listaDeEspera.first())
		}
	}
}

class Correlativa inherits Materia {
	const property correlativas
	override method puedeInscribirse(estudiante) {
		return super(estudiante) and 
		// TODO Podría usar una subtarea
		correlativas.all({mate => estudiante.materiasAprobadas().contains(mate)})
	}
}
class Crediticia inherits Materia {
	const property creditosRequeridos
	override method puedeInscribirse(estudiante) {
		return super(estudiante) and
		estudiante.creditos() >= creditosRequeridos
	}
}

class RequiereAnioAprobado inherits Materia {
	method materiasAnioPrevio() {
		// TODO Podría delegar en carrera.
		return self.carrera().materias().map({mate => mate.anio() == self.anio() - 1})
	}
	override method puedeInscribirse(estudiante) {
		return super(estudiante) and
		self.materiasAnioPrevio().all({mate => estudiante.materiasAprobadas().contains(mate)})
	}
}

class Carrera {
	const property nombre
	const property materias = []
}

class MateriaAprobada {
	const property alumno
	const property materia
	const property nota
}

// TODO Esto no se puede resolver con herencia porque no te permite modelar todas las combinaciones posibles.
class Elitista inherits Materia {
	override method darDeBaja(estudiante) {
		// TODO Repite código
		if (alumnosInscriptos.contains(estudiante)) {
			alumnosInscriptos.remove(estudiante)
		}
		if (not listaDeEspera.isEmpty()) {
			var mejorPromedio = self.listaDeEspera().max({alum => alum.promedio()})
			alumnosInscriptos.add(mejorPromedio)
		}
	}
}

class Avanzada inherits Materia {
	override method darDeBaja(estudiante) {
		// TODO Repite código
		if (alumnosInscriptos.contains(estudiante)) {
			alumnosInscriptos.remove(estudiante)
		}
		if (not listaDeEspera.isEmpty()) {
			var masAprobadas = self.listaDeEspera().max({alum => alum.materiasAprobadas().size()})
			alumnosInscriptos.add(masAprobadas)
		}
	}
}