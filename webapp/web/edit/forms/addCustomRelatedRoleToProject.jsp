<%-- $This file is distributed under the terms of the license in /doc/license.txt$ --%>

<jsp:include page="addCustomRole.jsp">
	<jsp:param name="roleDescriptor" value="related role" />
	<jsp:param name="typeSelectorLabel" value="related role" />
	<jsp:param name="roleType" value="http://vivoweb.org/ontology/core#Role" />
	
	<jsp:param name="roleActivityType_optionsType" value="HARDCODED_LITERALS" />
	<jsp:param name="roleActivityType_objectClassUri" value="" /> 	
	<jsp:param name="roleActivityType_literalOptions" 
    value='["", "Select type"],
           [ "http://vivoweb.org/ontology/core#ResearcherRole", "Researcher" ],
           [ "http://vivoweb.org/ontology/core#InvestigatorRole", "Investigator" ],
           [ "http://vivoweb.org/ontology/core#PrincipalInvestigatorRole", "Principal Investigator" ],
           [ "http://vivoweb.org/ontology/core#CoPrincipalInvestigatorRole", "Co-Principal Investigator" ]' />
</jsp:include>