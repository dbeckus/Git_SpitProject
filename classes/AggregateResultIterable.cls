global class AggregateResultIterable implements Iterable<AggregateResult> {
    AggregateResultIterator iterator {get; set;}
    
    global AggregateResultIterable() {
        this.iterator = new AggregateResultIterator();
    }
    global Iterator<AggregateResult> Iterator(){       
      return this.iterator;
   }
    global void setQuery(String query) {
    	iterator.setQuery(query);
    }
}