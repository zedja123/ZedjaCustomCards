--
--Milacresy Ceronius
--scripted by Zedja
--revised by Whispered
local s,id=GetID()
local SET_MILACRESY=0xe05
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon procedure: 1+ "Milacresy" Tuners + 1+ non-Tuner "Milacresy" monsters
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_MILACRESY),1,99,Synchro.NonTunerEx2(s.nontunerfilter),1,99,s.lnktunerfilter,nil,s.tunerreq)
	--For this card's Synchro Summon, you can treat 1 "Milacresy" Link Monster you control as a Tuner with a Level equal to its Link Rating
	for lk=1,6 do
		local e0=Effect.CreateEffect(c)
		e0:SetType(EFFECT_TYPE_FIELD)
		e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		e0:SetCode(EFFECT_SYNCHRO_LEVEL)
		e0:SetRange(LOCATION_EXTRA)
		e0:SetTargetRange(LOCATION_MZONE,0)
		e0:SetTarget(function(e,c) return c:IsSetCard(SET_MILACRESY) and c:IsLink(lk) end)
		e0:SetValue(lk)
		c:RegisterEffect(e0)
	end
	local e0b=Effect.CreateEffect(c)
	e0b:SetType(EFFECT_TYPE_FIELD)
	e0b:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e0b:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e0b:SetRange(LOCATION_EXTRA)
	e0b:SetTargetRange(LOCATION_MZONE,0)
	e0b:SetTarget(function(e,c) return c:IsSetCard(SET_MILACRESY) and c:IsLinkMonster() end)
	e0b:SetValue(function(e,sc) return sc and not sc:IsSetCard(SET_MILACRESY) end)
	c:RegisterEffect(e0b)
	--If this card is Synchro Summoned: You can shuffle up to 4 "Milacresy" cards from your GY and/or banishment into the Deck, then draw 1 card for every 2 cards shuffled into the Deck, also, until the end of this Chain, the activations and effects of your "Milacresy" cards cannot be negated
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(function(e) return e:GetHandler():IsSynchroSummoned() end)
	e1:SetTarget(s.tdtg)
	e1:SetOperation(s.tdop)
	c:RegisterEffect(e1)
	--If this Synchro Summoned card leaves the field: You can Special Summon 1 "Milacresy" monster from your Deck or Extra Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_MILACRESY}
function s.lnktunerfilter(c,sc,sumtype,tp)
	return c:IsSetCard(SET_MILACRESY,sc,sumtype,tp) and c:IsLinkMonster()
end
function s.nontunerfilter(c,sc,sumtype,tp)
	return c:IsSetCard(SET_MILACRESY,sc,sumtype,tp) and not c:IsLinkMonster()
end
function s.tunerreq(g,sc,tp)
	return g:FilterCount(Card.IsLinkMonster,nil)<=1
end
function s.tdfilter(c)
	return c:IsSetCard(SET_MILACRESY) and c:IsFaceup() and c:IsAbleToDeck()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE|LOCATION_REMOVED)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,4,nil)
	if #g>0 then
		Duel.HintSelection(g)
		if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
			local og=Duel.GetOperatedGroup()
			local ct=og:FilterCount(Card.IsLocation,nil,LOCATION_DECK|LOCATION_EXTRA)
			if ct>=2 and Duel.IsPlayerCanDraw(tp) then
				if og:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
				Duel.BreakEffect()
				Duel.Draw(tp,ct//2,REASON_EFFECT)
			end
		end
	end
	local c=e:GetHandler()
	--Also, until the end of this Chain, the activations and effects of your "Milacresy" cards cannot be negated
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_INACTIVATE)
	e1:SetValue(s.chainfilter)
	e1:SetReset(RESET_CHAIN)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_DISEFFECT)
	Duel.RegisterEffect(e2,tp)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_DISABLE)
	e3:SetTargetRange(LOCATION_ONFIELD,0)
	e3:SetTarget(function(e,c) return c:IsSetCard(SET_MILACRESY) end)
	e3:SetReset(RESET_CHAIN)
	Duel.RegisterEffect(e3,tp)
end
function s.chainfilter(e,ct)
	local p,te=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_EFFECT)
	return p==e:GetHandlerPlayer() and te:GetHandler():IsSetCard(SET_MILACRESY)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSynchroSummoned()
end
function s.spfilter(c,e,tp)
	if not (c:IsSetCard(SET_MILACRESY) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)) then return false end
	if c:IsLocation(LOCATION_EXTRA) then
		return Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
	end
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK|LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK|LOCATION_EXTRA,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
