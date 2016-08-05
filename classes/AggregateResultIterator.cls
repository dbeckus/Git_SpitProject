global class AggregateResultIterator implements Iterator<AggregateResult> {
   AggregateResult [] results {get;set;}
   // tracks which result item is returned
   Integer index {get; set;}
          
   global AggregateResultIterator() {
      index = 0;
	}
   global void setQuery(String query) {
       results = Database.query(query); 
   }
   global boolean hasNext(){
      return results != null && !results.isEmpty() && index < results.size();
   }   
    
   global AggregateResult next(){       
      return results[index++];           
   }      
}