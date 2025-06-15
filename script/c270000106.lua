--Wiccanthrope Reason
local s,id,o=GetID()
function s.initial_effect(c)
	-- Xyz Summon from Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,1})
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- Add "Wiccanthrope" Spell when banished
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,{id,2})
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end

function s.filter(c,e)
	return c:IsFaceup() and c:IsCanBeEffectTarget(e)
end

function s.validGroup(g,tp)
	local n=#g
	if n==1 then
		local c=g:GetFirst()
		return c:IsType(TYPE_XYZ) and c:IsSetCard(0xf11) and c:GetRank()<=4
			and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,g,tp)
	elseif n==2 then
		for tc in aux.Next(g) do
			if tc:IsType(TYPE_XYZ) then return false end
		end
		return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,g,tp)
	end
	return false
end

function s.xyzfilter(c,mg,tp)
	return c:IsSetCard(0xf11) and c:IsXyzSummonable(nil,mg,1,2) and Duel.GetLocationCountFromEx(tp,tp,mg,c)>0
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local mg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil,e)

	-- Filter valid cards only
	local filtered = Group.CreateGroup()
	for tc in mg:Iter() do
		if tc:IsFaceup() and tc:IsCanBeEffectTarget(e) then
			filtered:AddCard(tc)
		end
	end

	local tab = {}
	local tc = filtered:GetFirst()
	while tc do
		table.insert(tab, tc)
		tc = filtered:GetNext()
	end

	local count = #tab
	local soloList = {}
	local pairMap = {}

	for i = 1, count do
		local g1 = Group.FromCards(tab[i])
		if s.validGroup(g1, tp) then
			table.insert(soloList, tab[i])
		end
		for j = i + 1, count do
			local g2 = Group.FromCards(tab[i], tab[j])
			if s.validGroup(g2, tp) then
				local key = tab[i]:GetFieldID() .. "_" .. tab[j]:GetFieldID()
				pairMap[key] = Group.FromCards(tab[i], tab[j])
			end
		end
	end

	if chk==0 then
		return #soloList > 0 or next(pairMap) ~= nil
	end

	-- Now allow player to pick a first target (only from valid solo or first of a valid pair)
	local firstPool = Group.CreateGroup()
	for _,c in ipairs(soloList) do firstPool:AddCard(c) end
	for _,g in pairs(pairMap) do
		for tc in g:Iter() do firstPool:AddCard(tc) end
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local first = firstPool:Select(tp,1,1,nil):GetFirst()
	if not first then return end

	local g1 = Group.FromCards(first)
	if s.validGroup(g1, tp) then
		Duel.SetTargetCard(g1)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
		return
	end

	-- Find a valid second card that makes a valid pair
	local secondPool = Group.CreateGroup()
	for _,g in pairs(pairMap) do
		if g:IsContains(first) then
			for tc in g:Iter() do
				if tc ~= first then secondPool:AddCard(tc) end
			end
		end
	end

	if #secondPool == 0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local second = secondPool:Select(tp,1,1,nil):GetFirst()
	if not second then return end

	local finalGroup = Group.FromCards(first, second)
	Duel.SetTargetCard(finalGroup)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end





function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if not tg or tg:IsExists(Card.IsFacedown,1,nil) then return end
	s.xyzSummon(tp, tg)
end

-- Xyz Summon helper
function s.xyzSummon(tp,matGroup)
	if not matGroup or #matGroup==0 then return end
	local xyzg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil,matGroup,tp)
	if #xyzg==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sel=xyzg:Select(tp,1,1,nil)
	if #sel==0 then return end
	local xyz=sel:GetFirst()
	if xyz then
		Duel.XyzSummon(tp,xyz,nil,matGroup)
	end
end

function s.thfilter(c)
	return c:IsSetCard(0xf11) and c:IsType(TYPE_SPELL) and not c:IsCode(id) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
