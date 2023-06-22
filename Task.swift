import RealmSwift

class Task : object{
    @Presisted(primaryKey:true)var id : ObjectIdentifier
    
    @Persisted var title = ""
    
    @Presisted var contents = ""
    
    @Presisted var date = Date()
}
