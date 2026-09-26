--
--The Last Soul of Ashens
--scripted by Zedja
local s,id=GetID()
local SET_ASHENS=0xe02
function s.initial_effect(c)
	--Special Summon 1 "Ashens" monster from your Deck, or, if you control no monsters, you can Special Summon 1 Zombie monster from either GY instead, also you cannot Special Summon for the rest of this turn, except Zombie monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--You can banish this card from your GY; each player sends 1 Zombie monster from their Deck to the GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_ASHENS}
function s.deckspfilter(c,e,tp)
	return c:IsSetCard(SET_ASHENS) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.gyspfilter(c,e,tp)
	return c:IsRace(RACE_ZOMBIE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
		return Duel.IsExistingMatchingCard(s.deckspfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
			or (Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
			and Duel.IsExistingMatchingCard(s.gyspfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp))
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,PLAYER_EITHER,LOCATION_DECK|LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		local b1=Duel.IsExistingMatchingCard(s.deckspfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
		local b2=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
			and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.gyspfilter),tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp)
		local op=Duel.SelectEffect(tp,{b1,aux.Stringid(id,2)},{b2,aux.Stringid(id,3)})
		local g=Group.CreateGroup()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		if op==1 then
			g=Duel.SelectMatchingCard(tp,s.deckspfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		elseif op==2 then
			g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.gyspfilter),tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
		end
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	--Also you cannot Special Summon for the rest of this turn, except Zombie monsters
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,4))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c) return not c:IsRace(RACE_ZOMBIE) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	--Clock Lizard check
	aux.addTempLizardCheck(e:GetHandler(),tp,function(e,c) return not c:IsOriginalRace(RACE_ZOMBIE) end)
end
function s.tgfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,LOCATION_DECK,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,PLAYER_ALL,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	for _,p in ipairs({tp,1-tp}) do
		if Duel.IsExistingMatchingCard(s.tgfilter,p,LOCATION_DECK,0,1,nil) then
			Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TOGRAVE)
			g:Merge(Duel.SelectMatchingCard(p,s.tgfilter,p,LOCATION_DECK,0,1,1,nil))
		end
	end
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
