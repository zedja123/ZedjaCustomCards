--
--Ashens Ruler - Sulyvahn
--scripted by Zedja
local s,id=GetID()
local SET_ASHENS=0xe02
function s.initial_effect(c)
	--"Ashens" cards you control cannot be destroyed by card effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_ONFIELD,0)
	e1:SetTarget(function(e,c) return c:IsSetCard(SET_ASHENS) end)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--If you control no monsters, or only Zombie monsters: You can discard this card; Special Summon 1 "Ashens" monster from your Deck or GY, except "Ashens Ruler - Sulyvahn", and if you do, you cannot Special Summon for the rest of this turn, except Zombie monsters
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,{id,0})
	e2:SetCondition(s.spcon)
	e2:SetCost(Cost.SelfDiscard)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--If a Zombie monster or "Ashens" card you control would be sent to the GY or banished by an opponent's card effect, you can send this card to the GY instead
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SEND_REPLACE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.reptg)
	e3:SetValue(s.repval)
	e3:SetOperation(s.repop)
	c:RegisterEffect(e3)
end
s.listed_names={id}
s.listed_series={SET_ASHENS}
function s.nonzombiefilter(c)
	return c:IsFacedown() or not c:IsRace(RACE_ZOMBIE)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(s.nonzombiefilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_ASHENS) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		--And if you do, you cannot Special Summon for the rest of this turn, except Zombie monsters
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,2))
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
end
function s.repfilter(c,tp,rc)
	return c~=rc and c:IsControler(tp) and c:IsOnField() and c:IsFaceup()
		and ((c:IsMonster() and c:IsRace(RACE_ZOMBIE)) or c:IsSetCard(SET_ASHENS))
		and c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp and not c:IsReason(REASON_REPLACE)
		and (c:GetDestination()&(LOCATION_GRAVE|LOCATION_REMOVED))~=0
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGrave() and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
		and eg:IsExists(s.repfilter,1,nil,tp,c) end
	return Duel.SelectEffectYesNo(tp,c,aux.Stringid(id,1))
end
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer(),e:GetHandler())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT|REASON_REPLACE)
end
